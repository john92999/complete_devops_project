from flask import Flask, request, jsonify
import psycopg2
import redis
import os
import json

app = Flask(__name__)

# Redis connection
cache = redis.Redis(
    host=os.environ.get('REDIS_HOST', 'redis'),
    port=6379,
    decode_responses=True
)

# Postgres connection
def get_db():
    return psycopg2.connect(os.environ.get('DB_URL'))

# Init table
def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            email VARCHAR(100)
        )
    ''')
    conn.commit()
    cur.close()
    conn.close()

@app.route('/users', methods=['GET'])
def get_users():
    cached = cache.get('all_users')
    if cached:
        return jsonify({"source": "cache", "data": json.loads(cached)})
    
    conn = get_db()
    cur = conn.cursor()
    cur.execute('SELECT * FROM users')
    rows = cur.fetchall()
    cur.close()
    conn.close()
    
    data = [{"id": r[0], "name": r[1], "email": r[2]} for r in rows]
    cache.setex('all_users', 30, json.dumps(data))   # cache for 30 sec
    return jsonify({"source": "db", "data": data})

@app.route('/users', methods=['POST'])
def create_user():
    body = request.get_json()
    conn = get_db()
    cur = conn.cursor()
    cur.execute('INSERT INTO users (name, email) VALUES (%s, %s) RETURNING id',
                (body['name'], body['email']))
    user_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    cache.delete('all_users')    # invalidate cache
    return jsonify({"id": user_id, "name": body['name'], "email": body['email']})

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=True)