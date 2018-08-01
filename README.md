# ose-iotoolkit
----
# add project to anyuid SCC to allow running as root
oc adm policy add-scc-to-user anyuid system:serviceaccount:<project>:default
# Generate template and pipe to create (will build and deploy environment)
./gen_ose_yaml.sh | oc create -f -
