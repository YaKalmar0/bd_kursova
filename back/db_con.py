import mysql.connector
import pandas as pd
from config import db_creds

class DataBase():
    def __init__(self, creds):
        self.connect = mysql.connector.connect(
            user = creds['user'],
            password = creds['password'],
            host = creds['host'],
            database = creds['database']        
        )

        self.cursor = self.connect.cursor()   
    
    def __del__(self):
        self.cursor.close()
        self.connect.close()
    
    def call_proc(self, procedure_name, params=()):
        self.cursor.callproc(procedure_name, args=params)
        return self.prepare_data()
    
    def prepare_data(self):
        full_data = []
        for result in self.cursor.stored_results():
            column_names = [i[0] for i in result.description]
            #data = [column_names]
            #data.append(result.fetchall())
            data = pd.DataFrame(result.fetchall(), columns=column_names)
            full_data.append(data)
        return full_data
    

dataBase = DataBase(db_creds)
#response = dataBase.call_proc('get_all_locomotives')
#print('RESPONSE:', response[0].head())

'''
connect = mysql.connector.connect(
            user = db_creds['user'],
            password = db_creds['password'],
            host = db_creds['host'],
            database = db_creds['database']        
        )

cursor = connect.cursor()


cursor.execute("SHOW PROCEDURE STATUS WHERE db = 'Railway_Station'")
result = cursor.fetchall()
result = [i[1] for i in result]
print(result)
'''