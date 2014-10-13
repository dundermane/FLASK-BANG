from {name} import app

@app.route('/')
def index():
    return '<h1>Welcome to {site_name}</h1><p>Hello World!</p>'

@app.route('/hello')
def hello():
    return 'Hello Again!!'
