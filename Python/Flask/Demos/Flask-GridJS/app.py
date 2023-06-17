from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy

from .models import User

db = SQLAlchemy()


def create_app():
    app = Flask(__name__, instance_relative_config=False)
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)


    @app.route('/')
    def index():
        return render_template('index.html')

    return app




if __name__ == '__main__':
    app = create_app()
    app.run(debug=True)
