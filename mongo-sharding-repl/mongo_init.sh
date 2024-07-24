#!/bin/bash

###
# Инициализируем бд
###

docker compose exec -T configSrv mongosh --port 27019 --quiet <<EOF
rs.initiate(
  {
    _id : "config_rs",
    configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27019" }
    ]
  }
);
EOF

sleep 1

docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "rs1",
      members: [
        { _id : 0, host : "shard1-1:27018" },
        { _id : 1, host : "shard1-2:27018" },
        { _id : 2, host : "shard1-3:27018" }
      ]
    }
);
EOF

sleep 1

docker compose exec -T shard2-1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
    {
      _id : "rs2",
      members: [
        { _id : 0, host : "shard2-1:27018" },
        { _id : 1, host : "shard2-2:27018" },
        { _id : 2, host : "shard2-3:27018" }
      ]
    }
);
EOF

sleep 5

docker compose exec -T mongos_router mongosh --port 27017 --quiet <<EOF
sh.addShard( "rs1/shard1-1:27018");
sh.addShard( "rs1/shard1-2:27018");
sh.addShard( "rs1/shard1-3:27018");
sh.addShard( "rs2/shard2-1:27018");
sh.addShard( "rs2/shard2-2:27018");
sh.addShard( "rs2/shard2-3:27018");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } );
use somedb;

for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})

db.helloDoc.countDocuments();
EOF

sleep 1

docker compose exec -T shard1-1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF

sleep 1

docker compose exec -T shard2-1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
EOF