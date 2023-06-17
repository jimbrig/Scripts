from flask import jsonify, render_template, request

from .app import app


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/users', methods=['GET'])
def get_users():
    from .models import User
    users = User.query.all()
    return jsonify([user.to_dict() for user in users])
