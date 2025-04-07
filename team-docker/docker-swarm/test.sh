echo "Testing POST"
curl http://localhost:8080/api/users -d name=First -d email=someemail@someemailprovider.com

echo "Testing GET"
curl http://localhost:8080/api/users
