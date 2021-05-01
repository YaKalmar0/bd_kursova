procedures = ('get_all_locomotives()',
     'get_brigade_workers_younger_than(brig INT, years INT)',
     'get_cancelled_trips(reas TEXT, city1 TEXT, city2 TEXT)', 'get_delayed_trips(reas TEXT, city1 TEXT, city2 TEXT)',
     'get_dept_workers(dept TEXT)', 'get_free_locomotives_at(t TIME)',
     'get_head_of_dept(dept TEXT)', 'get_inspected_locomotives(d1 DATE, d2 DATE)',
     'get_locomotives_by_age(years INT)', 'get_locomotives_by_trips(numb INT)',
     'get_locomotives_inspections(numb INT)', 'get_locomotives_insp_trips(numb INT)',
     'get_locomotive_by_arr(arrival TIME)', 'get_number_of_workers()',
     'get_passengers_by_date(date DATE, abroad BOOL)', 'get_passengers_by_trip(trip INT)',
     'get_passengers_sex_age_lug(sex TEXT, age INT, luggage BOOL)', 'get_returned_tickets_by_date(d DATE)',
     'get_returned_tickets_by_route(city1 TEXT, city2 TEXT)', 'get_returned_tickets_by_trip(trip INT)',
     'get_sold_tickets(start DATE, end DATE)', 'get_sold_tickets_by_price(pr FLOAT)',
     'get_sold_tickets_by_route(city1 TEXT, city2 TEXT)', 'get_sold_tickets_by_travel_time(t TIME)',
     'get_trains_by_all_criterions(city1 TEXT, city2 TEXT, pr FLOAT, t TIME)', 'get_trains_by_route(city1 TEXT, city2 TEXT)',
     'get_trains_by_ticket_price(pr FLOAT)', 'get_trains_by_trip_duration(t TIME)',
     'get_trips_by_type_dest(type TEXT, dest TEXT)', 'get_unsold_tickets_by_date(start DATE, end DATE)',
     'get_unsold_tickets_by_route(city1 TEXT, city2 TEXT)', 'get_unsold_tickets_by_trip(trip INT)',
     'get_workers()', 'get_workers_by_brig_and_dep(brig INT, dept TEXT)',
     'get_workers_by_exp(years INT)', 'get_workers_by_locomotive(locom INT)',
     'get_workers_by_number_of_kids(kids INT)', 'get_workers_by_salary(sal INT)',
     'get_workers_by_sex(sex TEXT)', 'update_locomotive_inspection(locom INT)')

def get_procedures():
     procedures_string = '<h2>Procedures List</h2>'
     
     for el in sorted(procedures):
          procedures_string += '<p style="font-family:Menlo">' + el + '</p>'
     return procedures_string

def process_input(procedure, params, db):
     if params == 'pass_null':
          data = db.call_proc(procedure)
     else:
          params = params.split(',')
          data = db.call_proc(procedure, params)
     tables = [i.to_html(classes='data', header="true") for i in data]    
     return tables

