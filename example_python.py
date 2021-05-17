# Example Python script that reads data from a BigQuery table and creates
# a Tableau Hyper file, which is then published to Tableau Online as an
# extract data source.

from google.cloud import bigquery
bq_client = bigquery.Client.from_service_account_json('python-service-account.json')
# Get incremental data from Bigquery
query = """
    SELECT a.*
    FROM `test-project.test_table_a` a
    JOIN `test-project.test_table_b` b
    on a.column_ex = b.column_ex
"""
query_job = bq_client.query(query)
query_res = query_job.to_dataframe()

from tableauhyperapi import Connection, HyperProcess, SqlType, TableDefinition, \
    Telemetry, Inserter, CreateMode, TableName
from pathlib import Path
hyper_name = 'Extract_Example.hyper'
path_to_database = Path(hyper_name)

query_res['column_ex'] = query_res['column_ex'].astype(str)
query_res['column_ex2'] = query_res['column_ex2'].astype(str)
query_res['column_ex3'] = query_res['column_ex3'].astype(str)
query_res['column_ex4'] = query_res['column_ex4'].astype(str)
query_res['column_ex5'] = query_res['column_ex5'].astype(str)
query_res['column_ex6'] = query_res['column_ex6'].astype(str)

with HyperProcess(telemetry=Telemetry.SEND_USAGE_DATA_TO_TABLEAU) as hyper:
    with Connection(endpoint=hyper.endpoint,
                        database=path_to_database,
                        create_mode=CreateMode.CREATE_AND_REPLACE
                        ) as connection:
        connection.catalog.create_schema('Extract')
        # Define the hyper table (Same definition as the full refresh)
        example_table = TableDefinition(TableName('Extract','Extract'), [
            TableDefinition.Column('column_ex', SqlType.varchar(500)),
            TableDefinition.Column('column_ex2', SqlType.varchar(500)),
            TableDefinition.Column('column_ex_int', SqlType.int()),
            TableDefinition.Column('column_ex3', SqlType.varchar(500)),
            TableDefinition.Column('column_ex_int2', SqlType.int()),
            TableDefinition.Column('column_ex4', SqlType.varchar(500)),
            TableDefinition.Column('column_ex5', SqlType.varchar(500)),
            TableDefinition.Column('column_ex_int3', SqlType.int()),
            TableDefinition.Column('column_ex6', SqlType.varchar(500)),  
         ])
        print("The table is defined.")
        connection.catalog.create_table(table_definition=example_table)
        # Insert data from dataframe to hyper table
        with Inserter(connection, example_table) as inserter:
            for i in range(len(query_res)): 
                inserter.add_row(
                    [ query_res['column_ex'][i],  \
                     query_res['column_ex2'][i],  \
                     int(query_res['column_ex_int'][i]), \
                     query_res['column_ex3'][i], \
                     int(query_res['column_ex_int2'][i]), \
                     query_res['column_ex4'][i], \
                     query_res['column_ex5'][i], \
                     int(query_res['column_ex_int3'][i]), \
                     query_res['column_ex6'][i] \
                     ]
            )
            inserter.execute()
        table_names = connection.catalog.get_table_names("Extract")
    print("The connection to the Hyper file has been closed.")
print("The Hyper process has been shut down.")

import tableauserverclient as TSC
tab_file = open("tableau_api_access.txt", "r")
tab_filelines = tab_file.readlines()
tab_api_key = tab_filelines[1]
tab_api_name = tab_filelines[0]
tab_api_name = tab_api_name[0:18]
tableau_auth = TSC.PersonalAccessTokenAuth(tab_api_name, tab_api_key, 'name')
server = TSC.Server('https://us-east-1.online.tableau.com/')
server.version = '3.8'
project_name = 'Test'
project_id = ''
hyper_name = 'Extract_Example.hyper'
path_to_database = Path(hyper_name)

with server.auth.sign_in(tableau_auth):
        # Define publish mode
        publish_mode = TSC.Server.PublishMode.Append
        
        all_projects, pagination_item = server.projects.get()
        for project in TSC.Pager(server.projects):
            if project.name == project_name:
                project_id = project.id
    
        # Create the datasource object with the project_id
        datasource = TSC.DatasourceItem(project_id)
        
with server.auth.sign_in(tableau_auth):
        # Define publish mode 
        publish_mode = TSC.Server.PublishMode.Append
        
        print(f"Publishing {hyper_name} to {project_name}...")
        # Publish datasource
        datasource = server.datasources.publish(datasource, path_to_database, publish_mode)

