import sys, random, datetime as dt
from contextlib import contextmanager
import mysql.connector
from flask import Flask, request, session, jsonify
from werkzeug.security import generate_password_hash as gh, check_password_hash as ck

DB = dict(host='acela.proxy.rlwy.net', port=57933, user='root', password='gstQWnTHSPJMFGKKEfZMfXxrfSKKvlhc', database='aura_jewells')
app = Flask(__name__, static_folder='static', static_url_path='')
app.secret_key = 'aura-demo-secret-change-me'
app.json.default = str
today = lambda: dt.date.today().isoformat()
FIRST_ORDER_COUPON = 'FIRST500'
FIRST_ORDER_DISCOUNT = 500

@contextmanager
def db():
    c = mysql.connector.connect(**DB); cur = c.cursor(dictionary=True)
    try:
        yield cur; c.commit()
    except Exception:
        c.rollback(); raise
    finally:
        cur.close(); c.close()

def q(sql, a=(), one=False):
    with db() as cur:
        cur.execute(sql, a)
        if cur.description: return cur.fetchone() if one else cur.fetchall()

def user():
    return q('SELECT * FROM users WHERE id=%s', (session['uid'],), True) if 'uid' in session else None

def need(admin=False):
    u = user()
    if not u or (admin and not u['is_admin']): raise PermissionError
    return u

@app.errorhandler(PermissionError)
def _p(e): return jsonify(error='Please login (admin only area)'), 401
@app.errorhandler(ValueError)
def _v(e): return jsonify(error=str(e)), 400

def rates(): return {r['purity']: r['price'] for r in q('SELECT * FROM rates')}

def price(p, R):
    rate = R[p['purity']]; val = p['weight'] * rate
    sub = val + p['making'] + p['stone']; tax = sub * .03
    original = sub + tax
    final = p['sale_price'] if (p.get('on_sale') and p.get('sale_price')) else original
    return {**p, 'rate': rate, 'val': val, 'tax': tax, 'original': original, 'price': final}

def balance(cid):
    return q("SELECT COALESCE(SUM(qty-used),0) b FROM gold_bookings WHERE cid=%s AND status<>'Cancelled'", (cid,), True)['b']

def nextid(table, prefix, base, width=0):
    n = q(f'SELECT COUNT(*) n FROM {table}', one=True)['n'] + 1
    return prefix + (str(n).zfill(width) if width else str(base + n))

@app.route('/')
def home(): return app.send_static_file('index.html')

# ---------- Catalogue ----------
@app.route('/api/products')
def products():
    R = rates(); hist = {}
    for h in q('SELECT purity,d,price FROM price_history ORDER BY d'):
        hist.setdefault(h['purity'], []).append({'d': h['d'], 'price': h['price']})
    upd = q('SELECT MAX(updated) u FROM rates', one=True)['u']
    return jsonify(products=[price(p, R) for p in q('SELECT * FROM products')], rates=R, history=hist, updated=upd)

# ---------- Auth ----------
@app.route('/api/me')
def me():
    u = user()
    if not u: return jsonify(user=None)
    n = q('SELECT COUNT(*) n FROM orders WHERE cid=%s', (u['cid'],), True)['n']
    return jsonify(user={'cid': u['cid'], 'name': u['name'], 'email': u['email'], 'mobile': u['mobile'],
                          'admin': u['is_admin'], 'orders': n, 'gold': balance(u['cid'])})

@app.route('/api/register', methods=['POST'])
def register():
    d = request.json
    if not all(d.get(k) for k in ('name', 'email', 'mobile', 'password')) or d['password'] != d.get('confirm'):
        raise ValueError('Fill all fields; passwords must match')
    if q('SELECT 1 FROM users WHERE email=%s', (d['email'],)): raise ValueError('Email already registered')
    cid = nextid('users', 'AUR', 10000)
    q('INSERT INTO users(cid,name,email,mobile,pw) VALUES(%s,%s,%s,%s,%s)',
      (cid, d['name'], d['email'], d['mobile'], gh(d['password'])))
    session['uid'] = q('SELECT id FROM users WHERE cid=%s', (cid,), True)['id']
    return jsonify(ok=True, cid=cid)

@app.route('/api/login', methods=['POST'])
def login():
    d = request.json
    u = q('SELECT * FROM users WHERE email=%s OR mobile=%s', (d['id'], d['id']), True)
    if not u or not ck(u['pw'], d['password']): raise ValueError('Invalid login')
    session['uid'] = u['id']; return jsonify(ok=True)

@app.route('/api/logout', methods=['POST'])
def logout(): session.clear(); return jsonify(ok=True)

@app.route('/api/forgot-password', methods=['POST'])
def forgot():
    # Demo-only reset: generates a temporary password and returns it directly
    # (a real deployment would email a reset link instead of showing it here).
    d = request.json
    u = q('SELECT * FROM users WHERE email=%s', (d['email'],), True)
    if not u: raise ValueError('No account with that email')
    temp = 'aura' + str(random.randint(1000, 9999))
    q('UPDATE users SET pw=%s WHERE id=%s', (gh(temp), u['id']))
    return jsonify(ok=True, temp_password=temp)

# ---------- Orders ----------
@app.route('/api/orders', methods=['GET', 'POST'])
def orders():
    u = need()
    if request.method == 'GET':
        return jsonify(q('SELECT * FROM orders WHERE cid=%s ORDER BY created DESC,id DESC', (u['cid'],)))
    d = request.json; R = rates(); sub = 0; lines = []
    if not d.get('items') or not d.get('address'): raise ValueError('Cart or address missing')
    for it in d['items']:
        p = q('SELECT * FROM products WHERE code=%s', (it['code'],), True)
        if not p or p['stock'] < it['qty']: raise ValueError(f"{it['code']} is out of stock")
        pr = price(p, R); sub += pr['price'] * it['qty']; lines.append((p['code'], it['qty'], pr['price']))
    discount = 0
    coupon = (d.get('coupon') or '').strip().upper()
    if coupon:
        if coupon != FIRST_ORDER_COUPON: raise ValueError('Invalid coupon code')
        prior = q('SELECT COUNT(*) n FROM orders WHERE cid=%s', (u['cid'],), True)['n']
        if prior > 0: raise ValueError('FIRST500 is valid only on your first order')
        discount = min(FIRST_ORDER_DISCOUNT, sub)
    total = sub - discount + (500 if (sub - discount) < 25000 else 0)
    oid = nextid('orders', 'AURORD', 10025)
    demo = d['pay'].startswith('Demo')
    with db() as cur:
        cur.execute('INSERT INTO orders VALUES(%s,%s,%s,%s,%s,%s,%s,%s)',
                     (oid, u['cid'], total, d['pay'], 'Paid' if demo else 'Pending', 'Pending', d['address'], today()))
        for c, n, unit in lines:
            cur.execute('INSERT INTO order_items(order_id,code,qty,unit) VALUES(%s,%s,%s,%s)', (oid, c, n, unit))
            cur.execute('UPDATE products SET stock=stock-%s WHERE code=%s', (n, c))
    return jsonify(ok=True, id=oid, total=total, discount=discount)

# ---------- Gold / Digital Gold ----------
@app.route('/api/gold')
def gold():
    u = need(); c = u['cid']
    return jsonify(balance=balance(c),
        bookings=q('SELECT * FROM gold_bookings WHERE cid=%s ORDER BY created DESC,id DESC', (c,)),
        tx=q('SELECT * FROM gold_tx WHERE cid=%s ORDER BY id DESC', (c,)),
        red=q('SELECT * FROM redemptions WHERE cid=%s ORDER BY created DESC', (c,)))

@app.route('/api/gold/book', methods=['POST'])
def book():
    u = need(); d = request.json; qty = float(d['qty']); pu = d['purity']
    if qty <= 0 or pu not in ('24', '22', '18'): raise ValueError('Invalid booking')
    rate = rates()[pu]; bid = nextid('gold_bookings', 'GB2026', 0, 4)
    q('INSERT INTO gold_bookings(id,cid,purity,qty,rate,val,created) VALUES(%s,%s,%s,%s,%s,%s,%s)',
      (bid, u['cid'], pu, qty, rate, qty * rate, today()))
    q("INSERT INTO gold_tx(cid,type,ref,grams,created) VALUES(%s,'Booking',%s,%s,%s)", (u['cid'], bid, qty, today()))
    return jsonify(ok=True, id=bid)

@app.route('/api/gold/redeem', methods=['POST'])
def redeem():
    u = need(); R = rates()
    p = q("SELECT * FROM products WHERE code=%s AND cat='gold' AND stock>0", (request.json['code'],), True)
    if not p: raise ValueError('Product not available for redemption')
    pr = price(p, R); have = balance(u['cid']); use = min(have, p['weight'])
    if use <= 0: raise ValueError('No gold balance')
    extra = max(0, pr['price'] - use * pr['rate']); need_g = use; rid = nextid('redemptions', 'RD', 1000)
    with db() as cur:
        cur.execute("SELECT * FROM gold_bookings WHERE cid=%s AND status<>'Cancelled' AND used<qty ORDER BY created,id", (u['cid'],))
        for b in cur.fetchall():
            t = min(need_g, b['qty'] - b['used']); need_g -= t
            cur.execute('UPDATE gold_bookings SET used=used+%s,status=IF(used+%s>=qty,%s,%s) WHERE id=%s',
                        (t, t, 'Redeemed', 'Partially Redeemed', b['id']))
        cur.execute('INSERT INTO redemptions VALUES(%s,%s,%s,%s,%s,%s,%s)', (rid, u['cid'], p['name'], use, extra, 'Completed', today()))
        cur.execute("INSERT INTO gold_tx(cid,type,ref,grams,created) VALUES(%s,'Redemption',%s,%s,%s)", (u['cid'], rid, -use, today()))
        cur.execute('UPDATE products SET stock=stock-1 WHERE code=%s', (p['code'],))
    return jsonify(ok=True, used=use, remaining=have - use, extra=extra)

# ---------- Contact / Appointments ----------
@app.route('/api/contact', methods=['POST'])
def contact():
    d = request.json
    if not all(d.get(k) for k in ('name', 'email', 'message')): raise ValueError('Fill all fields')
    q('INSERT INTO contact_messages(name,email,message) VALUES(%s,%s,%s)', (d['name'], d['email'], d['message']))
    return jsonify(ok=True)

@app.route('/api/appointment', methods=['POST'])
def appointment():
    d = request.json
    if not all(d.get(k) for k in ('name', 'email', 'mobile', 'pdate', 'ptime')): raise ValueError('Fill all fields')
    q('INSERT INTO appointments(name,email,mobile,pdate,ptime,purpose) VALUES(%s,%s,%s,%s,%s,%s)',
      (d['name'], d['email'], d['mobile'], d['pdate'], d['ptime'], d.get('purpose', '')))
    return jsonify(ok=True)

# ---------- Customize Your Order ----------
@app.route('/api/custom-order', methods=['POST'])
def custom_order():
    d = request.json
    if not all(d.get(k) for k in ('name', 'mobile', 'category', 'details')):
        raise ValueError('Please fill in your name, mobile, category and design details')
    u = user(); cid = u['cid'] if u else None
    oid = nextid('custom_orders', 'CUST', 1000)
    q('INSERT INTO custom_orders(id,cid,name,email,mobile,category,metal,budget,details) VALUES(%s,%s,%s,%s,%s,%s,%s,%s,%s)',
      (oid, cid, d['name'], d.get('email', ''), d['mobile'], d['category'], d.get('metal', ''), d.get('budget', ''), d['details']))
    return jsonify(ok=True, id=oid)

# ---------- Admin ----------
@app.route('/api/admin/data')
def admin_data():
    need(True)
    return jsonify(
        customers=q("SELECT u.cid,u.name,u.email,u.mobile,(SELECT COUNT(*) FROM orders o WHERE o.cid=u.cid) orders,"
                    "(SELECT COALESCE(SUM(qty-used),0) FROM gold_bookings g WHERE g.cid=u.cid AND g.status<>'Cancelled') gold "
                    "FROM users u WHERE is_admin=0"),
        orders=q('SELECT * FROM orders ORDER BY created DESC,id DESC'),
        bookings=q('SELECT g.*,u.name FROM gold_bookings g JOIN users u ON u.cid=g.cid ORDER BY g.created DESC'),
        redemptions=q('SELECT r.*,u.name FROM redemptions r JOIN users u ON u.cid=r.cid ORDER BY r.created DESC'),
        bycat=q('SELECT p.cat,SUM(i.qty*i.unit) s FROM order_items i JOIN products p ON p.code=i.code GROUP BY p.cat'),
        monthly=q("SELECT DATE_FORMAT(created,'%Y-%m') m,COUNT(*) n FROM orders GROUP BY m ORDER BY m"),
        history=q('SELECT * FROM price_history ORDER BY d DESC LIMIT 120'),
        messages=q('SELECT * FROM contact_messages ORDER BY created DESC LIMIT 50'),
        appointments=q('SELECT * FROM appointments ORDER BY pdate DESC,ptime DESC LIMIT 100'),
        custom_orders=q('SELECT * FROM custom_orders ORDER BY created DESC LIMIT 100'),
        sales=q('SELECT COALESCE(SUM(total),0) s FROM orders', one=True)['s'])

@app.route('/api/admin/custom-order', methods=['POST'])
def admin_custom_order():
    need(True); d = request.json
    q('UPDATE custom_orders SET status=%s WHERE id=%s', (d['status'], d['id'])); return jsonify(ok=True)

@app.route('/api/admin/order', methods=['POST'])
def admin_order():
    need(True); d = request.json
    q('UPDATE orders SET status=%s WHERE id=%s', (d['status'], d['id'])); return jsonify(ok=True)

@app.route('/api/admin/booking', methods=['POST'])
def admin_booking():
    need(True); d = request.json
    q('UPDATE gold_bookings SET status=%s WHERE id=%s', (d['status'], d['id'])); return jsonify(ok=True)

@app.route('/api/admin/stock', methods=['POST'])
def admin_stock():
    need(True); d = request.json
    q('UPDATE products SET stock=%s WHERE code=%s', (d['stock'], d['code'])); return jsonify(ok=True)

@app.route('/api/admin/product', methods=['POST'])
def admin_product():
    need(True); d = request.json
    exists = q('SELECT 1 FROM products WHERE code=%s', (d['code'],))
    fields = ('name', 'cat', 'type', 'purity', 'weight', 'making', 'stone', 'stock', 'image',
              'carat', 'cut', 'clarity', 'colour', 'certificate', 'description', 'featured',
              'new_arrival', 'on_sale', 'sale_price', 'wedding', 'gifting', 'mens', 'kids', 'daily_wear')
    vals = [d.get(f) if d.get(f) not in ('', None) else None for f in fields]
    if exists:
        set_sql = ','.join(f'{f}=%s' for f in fields)
        q(f'UPDATE products SET {set_sql} WHERE code=%s', (*vals, d['code']))
    else:
        q(f'INSERT INTO products(code,{",".join(fields)},created) VALUES(%s,{",".join(["%s"]*len(fields))},%s)',
          (d['code'], *vals, today()))
    return jsonify(ok=True)

@app.route('/api/admin/product/<code>', methods=['DELETE'])
def admin_delete_product(code):
    need(True)
    q('DELETE FROM products WHERE code=%s', (code,)); return jsonify(ok=True)

@app.route('/api/admin/prices', methods=['POST'])
def admin_prices():
    need(True)
    for k, v in request.json.items():
        q('UPDATE rates SET price=%s,updated=NOW() WHERE purity=%s', (v, k))
        q('INSERT INTO price_history VALUES(%s,%s,%s) ON DUPLICATE KEY UPDATE price=%s', (k, today(), v, v))
    return jsonify(ok=True)

# ---------- First-time setup ----------
def setup():
    raw = mysql.connector.connect(host=DB['host'], user=DB['user'], password=DB['password']); cur = raw.cursor()
    for s in open('schema.sql', encoding='utf-8').read().split(';'):
        if s.strip(): cur.execute(s)
    raw.commit(); cur.close(); raw.close()
    for cid, n, e, m, pw, adm in [
        ('AUR10001', 'Demo Customer', 'demo@aura.com', '9000000001', 'demo123', 0),
        ('AUR10002', 'Test Customer', 'test@aura.com', '9000000002', 'test123', 0),
        ('ADMIN', 'Admin', 'admin@aura.com', '9000000000', 'admin123', 1)]:
        q('INSERT INTO users(cid,name,email,mobile,pw,is_admin) VALUES(%s,%s,%s,%s,%s,%s)', (cid, n, e, m, gh(pw), adm))
    R = rates(); random.seed(7)
    for k, v in R.items():
        for i in range(29, -1, -1):
            f = 1 + (random.random() - .5) * .04 * (i / 29)
            q('INSERT INTO price_history VALUES(%s,%s,%s)',
              (k, (dt.date.today() - dt.timedelta(days=i)).isoformat(), round(v * f) if i else v))
    q("INSERT INTO gold_bookings VALUES"
      "('GB20260001','AUR10001','22',10,0,12290,122900,'Active','2026-09-01'),"
      "('GB20260002','AUR10002','22',5,1,12290,61450,'Partially Redeemed','2026-09-05')")
    q("INSERT INTO gold_tx(cid,type,ref,grams,created) VALUES"
      "('AUR10001','Booking','GB20260001',10,'2026-09-01'),"
      "('AUR10002','Booking','GB20260002',5,'2026-09-05'),"
      "('AUR10002','Redemption','RD1000',-1,'2026-09-06')")
    print('Database ready. Run: python app.py')

if __name__ == '__main__':
    setup() if len(sys.argv) > 1 and sys.argv[1] == 'setup' else app.run(debug=True)
