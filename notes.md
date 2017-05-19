# NOTES

# Cipher
create (c:City {name:'Bern', latitude: 46.9479, longitude: 7.4446})

c = Graph::City.create(name: 'Teststadt', latitude: 46.9479, longitude: 7.4446)

match (c:City) with c call spatial.addNode('test_layer', c) yield node return count(*)


# Migrieren
NEO4J_URL="http://neo4j:test@localhost:17475" rake neo4j:migrate
