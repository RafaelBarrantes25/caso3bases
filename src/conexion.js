const sql = require('mssql');
module.exports = {
    Ejecutar: async (query) => {
        config = {
            user: 'sa',
            password: 'PruebaHola1!',
            server: 'localhost', // Or your server IP address
            database: 'master',
            port: 1400,
            options: {
                encrypt: false, // Use true if you are on Azure SQL
                trustServerCertificate: true // Change to false for production environments
            },
            pool: {
                max: 25,                  // Maximum number of simultaneous connections allowed
                min: 5,                   // Minimum number of idle connections maintained
                idleTimeoutMillis: 30000  // Time (in ms) before closing an inactive connection
            }
        };

        let retVal = null;
        try 
        {
            console.log("Connecting to SQL Server...");
            let pool = await sql.connect(config);
            console.log("Connected successfully!");
            console.log(query);

            let result = await pool.request().query(query);
            console.dir(result);
            retVal = result.recordset;
        }
        catch(err)
        {
            console.error('Database operation failed: ', err);
        }
        finally {
        // 4. Close the connection pool when your app shuts down
        await sql.close();
        return retVal;
    }


    }// docker exec -it sqlserver-db bash /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P soyAdmin#123

}