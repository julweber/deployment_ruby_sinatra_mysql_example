# Deployment example for Cf using ruby, sinatra and mysql backing service

## Notes

curl ruby-sinatra-mysql-blue.cfapps.io/ping

## Deployment

```
cd scripts
bash 0_prepare_cf_env.sh
bash base_deployment.sh
```


### Getting Started

Install the app by pushing it to your Cloud Foundry and binding with the Riak CS service

Example:

    $ cf push mysqltest --no-start
    $ cf create-service p-mysql 100mb mydb
    $ cf bind-service mysqltest mydb
    $ cf restart mysqltest

### Endpoints

Set base url:
```
# TODO: exchange accordingly
export BASE_URL="http://ruby-sinatra-mysql-blue.example.com"
```

#### GET /env
```
curl "$BASE_URL/env"
```

#### GET /database
```
curl "$BASE_URL/database"
```

#### POST /:key

Stores a key:value pair in the MySQL database.

```
export KEY="mykey"
export DATA="my_data_to_insert"
curl -X POST "$BASE_URL/store/$KEY" -d "$DATA"
```

#### GET /:key

Returns the value stored in the database for a specified key.

```
export KEY="mykey"
curl "$BASE_URL/store/$KEY"
```
