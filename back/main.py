from flask import Flask, render_template, request, redirect, url_for
from db_con import dataBase
from helpers import get_procedures, process_input
app = Flask(__name__)       


@app.route('/', methods=['POST', 'GET'])
def hello_world():
    if request.method == 'GET':
        return render_template('base.html', procedures=get_procedures())
    elif request.method == 'POST':
        procedure = request.form.get('procedure')
        params = request.form.get('params')
        if not params:
            params = 'pass_null'
        return redirect(url_for('home', procedure=procedure, params=params))
        

@app.route('/home/<string:procedure>/<params>', methods=['GET'])
def home(procedure, params):
    tables = process_input(procedure, params, dataBase)   
    return render_template('table.html', tables=tables)

if __name__ == '__main__':
    app.run()
