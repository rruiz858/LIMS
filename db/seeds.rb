ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0;')
ActiveRecord::Base.connection.execute('TRUNCATE order_statuses;')
ActiveRecord::Base.connection.execute('TRUNCATE users;')
ActiveRecord::Base.connection.execute('TRUNCATE roles;')
ActiveRecord::Base.connection.execute('TRUNCATE order_concentrations;')
ActiveRecord::Base.connection.execute('TRUNCATE agreement_statuses;')
ActiveRecord::Base.connection.execute('TRUNCATE contact_types;')

OrderStatus.create! id: 1, name: "adding_chemicals"
OrderStatus.create! id: 2, name: "plate_details"
OrderStatus.create! id: 3, name: "review"
OrderStatus.create! id: 4, name: "submitted"
OrderStatus.create! id: 5, name: "canceled"
OrderStatus.create! id: 6, name: "created"

AgreementStatus.create! id: 1, status: "New"
AgreementStatus.create! id: 2, status: "In Progress"
AgreementStatus.create! id: 3, status: "Active"
AgreementStatus.create! id: 4, status: "Complete"
AgreementStatus.create! id: 5, status: "Revoked"

ContactType.create! id: 1, kind: "Project Manager"
ContactType.create! id: 2, kind: "Shipping Recipient"
ContactType.create! id: 3, kind: "Project Other"

OrderConcentration.create! id: 1, concentration: 0, unit: "mg"
OrderConcentration.create! id: 2, concentration: 20, unit: "ul"
OrderConcentration.create! id: 3, concentration: 100, unit: "ul"



# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).


@admin = Role.create!(role_type: 'admin')
@chemadmin = Role.create!(role_type: 'chemadmin')
@chemcurator = Role.create!(role_type: 'chemcurator')
@cor = Role.create!(role_type: 'cor')
@postdoc = Role.create!(role_type: 'postdoc')
@contractadmin = Role.create!(role_type: 'contractadmin')




@admin.users.create(email: 'ruiz-veve.raymond@epa.gov',
                    f_name: 'Raymond',
                    l_name: 'Ruiz-Veve',
                    username: 'rruizvev')
@admin.users.create(email: 'edwards.jeff@epa.gov',
                    f_name: 'Jeff',
                    l_name: 'Edwards',
                    username: 'jedwar03')
@chemcurator.users.create(email: 'thillainadarajah.inthirany@epa.gov',
                    f_name: 'Indira',
                    l_name: 'thillainadarajah',
                    username: 'ithillai')
@chemcurator.users.create(email: 'williams.antony@epa.gov',
                          f_name: 'antony',
                          l_name: 'williams',
                          username: 'awilli04')

@chemadmin.users.create(email: 'grulke.chris@epa.gov',
                    f_name: 'Chris',
                    l_name: 'Grulke',
                    username: 'cgrulke')

@chemadmin.users.create(email: 'richard.ann@epa.gov',
                    f_name: 'Ann',
                    l_name: 'Richard',
                    username: 'aricha02')
@cor.users.create(email: 'martin.matt@epa.gov',
                    f_name: 'Matt',
                    l_name: 'Martin',
                    username: 'mmarti02')

@cor.users.create(email: 'simmons.steve@epa.gov',
                    f_name: 'Steve',
                    l_name: 'Simmons',
                    username: 'ssimmons')

@cor.users.create(email: 'judson.richard@epa.gov',
                    f_name: 'Richard',
                    l_name: 'Judson',
                    username: 'rjudson')
@cor.users.create(email: 'wambaugh.john@epa.gov',
                  f_name: 'John',
                  l_name: 'Wambaugh',
                  username: 'jwambaug')


ActiveRecord::Base.connection.execute('SET foreign_key_checks = 1;')

