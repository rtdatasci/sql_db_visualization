import sqlite3

## Connectt to SQlite
connection=sqlite3.connect("samples.db")

# Create a cursor object to insert record,create table

cursor=connection.cursor()

## create the table
table_info="""
CREATE TABLE samples (STUDYID VARCHAR(25),SAMPLEID VARCHAR(25),
SPECIMEN VARCHAR(25),VENDOR VARCHAR(25), ASSAY VARCHAR(25));

"""
cursor.execute(table_info)

## Insert Some more records

cursor.execute('''INSERT INTO samples values('abc123','889003C','SLIDE','VENDOR1','IHC')''')
cursor.execute('''INSERT INTO samples values('abc123','889004C','SLIDE','VENDOR1','IHC')''')
cursor.execute('''INSERT INTO samples values('abc123','889005C','SLIDE','VENDOR1','IHC')''')
cursor.execute('''INSERT INTO samples values('abc123','889006C','SLIDE','VENDOR1','IHC')''')
cursor.execute('''INSERT INTO samples values('abc123','889003R','RNA','VENDOR2','NGS')''')
cursor.execute('''INSERT INTO samples values('abc123','889004R','RNA','VENDOR2','NGS')''')
cursor.execute('''INSERT INTO samples values('abc123','889005R','RNA','VENDOR2','NGS')''')
cursor.execute('''INSERT INTO samples values('abc123','889006R','RNA','VENDOR2','NGS')''')
cursor.execute('''INSERT INTO samples values('abc123','889003D','DNA','VENDOR3','NGS')''')
cursor.execute('''INSERT INTO samples values('abc123','889004D','DNA','VENDOR3','NGS')''')
cursor.execute('''INSERT INTO samples values('abc123','889005D','DNA','VENDOR3','NGS')''')
cursor.execute('''INSERT INTO samples values('abc123','889006RD','DNA','VENDOR3','NGS')''')

## Disspaly ALl the records

print("The inserted records are")
data=cursor.execute('''Select * from samples''')
for row in data:
    print(row)

## Commit your changes int he databse
connection.commit()
connection.close()