https://github.com/dbcli/mssql-cli

A command-line client for SQL Server with auto-completion and syntax highlighting 

DEPRECATION NOTICE mssql-cli is on the path to deprecation, 
and will be fully replaced by the new go-sqlcmd utility once it becomes generally available. 
e are actively in development for the new sqlcmd, and would love to hear feedback on it here!


# Import the public repository GPG keys
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

# Register the Microsoft Ubuntu repository
sudo apt-add-repository https://packages.microsoft.com/ubuntu/18.04/prod

# Update the list of products
sudo apt-get update

# Install mssql-cli
sudo apt-get install mssql-cli

# Install missing dependencies
sudo apt-get install -f

-------------------------------------------------------------------------------------------------------------------------------
# install

python -m pip install mssql-cli

# Connect to Server

mssql-cli -S <server URL> -d <database name> -U <username> -P <password>

# Show Options

mssql-cli --help

