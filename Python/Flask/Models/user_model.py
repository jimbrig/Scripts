from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import check_password_hash, generate_password_hash

db = SQLAlchemy()


class User(db.Model):
    """User Model
        :param db.Model: SQLAlchemy Model
        :type db.Model: SQLAlchemy

        :return: User Model Class
        :rtype: User

        :Example:
        u = User(
            first_name='John',
            last_name='Doe',
            email='John.Doe@email.com',
            password='password'
        )
        db.session.add(u)
        db.session.commit()

        # query all users
        users = User.query.all()

        # update a user
        u = User.query.get(1)
        u.first_name = 'Jane'
        db.session.add(u)
        db.session.commit()

        # delete a user
        u = User.query.get(1)
        db.session.delete(u)
        db.session.commit()
    """
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(50))
    last_name = db.Column(db.String(50))
    email = db.Column(db.String(50), unique=True)
    password = db.Column(db.String(200))

    def __init__(self, first_name, last_name, email, password):
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.password = generate_password_hash(password)

    def __repr__(self):
        return f'<User {self.email}>'

    @property
    def full_name(self):
        return f'{self.first_name} {self.last_name}'

    def check_password(self, password):
        return check_password_hash(self.password, password)

    @property
    def is_authenticated(self):
        return True

    @property
    def is_active(self):
        return True

    @property
    def is_anonymous(self):
        return False

    def get_id(self):
        return self.email
