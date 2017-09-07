# database-loader
## Description

A chef cookbook which goal is to simplify loading .csv-files into a mysql-database in production environments. Loading .csv-files to a database is mostly done via a simple "truncate" and a following "load from file" command, which makes it impossible to use for environments with high-availability. Furthermore, most database-managing cookbooks (like the chef-official "database"-cookbook) have a lot of dependencies on tools which you can not install in production environments like "gcc" or "libmysql-dev". This cookbook tries to overcome these problems and help you managing your mysql-database.

We assume, that you want to have your (configuration-) CSV-files under version control in a git-repo and a pre-compiled `mysql2` binary gem.  

For pre-compiling of the `mysql2-gem` you may use the `gem-compiler` by luislavena [on github](https://github.com/luislavena/gem-compiler). You have to do the compile on a system with the same operating system than your destination system. Furthermore, you need the gcc compiler
`gem install gem-compiler
 gem fetch mysql2
 gem compile mysql2-0.4.4.gem
`
You have to pay attention, that your ruby-version on your compiling system matches the ruby-version on your destination system (for example ruby-2.1.1 that comes with chef-client) 


## Using the cookbook
The cookbook currently provides the mysql2-gem pre-compiled for `centos6`, `centos7` and `ubuntu1404` and `ruby2.1.0` via cookbook-file.  
The Ruby-LWRP always compare the csv-file with the matching table in the database. Only entries that differ in the table are deleted and inserted again. New entries are inserted one by one. **The cookbook will never truncate a whole table!** This is very important for environments, where you get service impacts with changes on tables, so you want to have the changes as little as possible.

### Recipe: Install `mysql2-gem`
To install the mysql2-gem in the chef working directory, you have to place the default recipe in your run_list  
`recipe[database-loader]` 

### Lightweight-ressource-provider (LWRP)
We offer an LWRP that can be used in any other cookbook to manage a mysql database. To use this LWRPs you have to include this cookbook in your cookbook first.
```ruby
include_recipe 'database-loader'`  
```

`database_loader 'myCSV' do
    host '127.0.0.1'
    username      'admin'
    password      'admin'
    database      'example-settings'
    csv_filename  'example.csv'
    csv_filepath  '/tmp'
    action :sync
  end
end`

Attribute | Type | Description | Mandatory
----------| ----- | --------   | --------
host |  String | The MYSQL-Database Host. 127.0.0.1 for localhost | yes
username | String | The username to login to the database. Needs to have sufficient rights | yes
password | String | Password for the username | yes
database | String | The database you want to manage | yes
csv_filename | String | The name of the .csv file that you are trying to sync with the database | yes
csv_filepath | String | where the .csv-file is located | yes
table_header | Array | If your .csv file has less colums than your table you need to define them manually | no

If you just want to change some colums in your table and not the complete one, you need to define the table_headers manually, so that the LWRP knows, which colums in your .csv-file maps which colums in the database table

## Attributes
You can define the precompiled `mysql2` to be used for different operating systems.  
```ruby
default['database-loader']['package_selector'] =    {
  'rhel' => { '6' => 'mysql2-0.4.4-x86_64-centos6.gem', '7' => 'mysql2-0.4.4-x86_64-centos7.gem' },
  'debian' => { 'none' => 'none' }
}
```

## Continuous Integration
We created a gitlab-ci file that can be used to compile the gems for different operating systems. The automatic building process is currently deactivated, as we don't want to build on every commit

## To Do
* add an kitchen-ci-pipeline for ubuntu and centos
* fix the bug for tables with auto-increment
* test the why-run
* import also files different than .csv
* Try to make use of sql "update" statement

## Contributing

1. Answer the question "Does it make sense to have it in this repository" with YES
2. Fork the repository
3. Create a named feature branch (like feature/add_component_x)
4. Do your changes (do not forget the tests)
5. Run the tests, ensuring they all pass (and you are not decreasing the test coverage)
6. Rebase it to the latest master (to ensure your changes do apply)
7. Squash your commits to a small amount of logical separated commits (e.g. to avoid commits with something like "reverted or fixed last commit" in the commit chain)
8. Submit a Merge Request to the master branch of this repository

## Licence
Licensed under MIT license, see the LICENSE file at the top-level directory

## Maintainer

Jannik Zinkl, Deutsche Telekom Technik GmbH, jannik.zinkl@telekom.de  
Tilman Marquart, Deutsche Telekom Technik GmbH, tilman.marquart@telekom.de