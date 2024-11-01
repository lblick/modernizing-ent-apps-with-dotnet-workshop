





## Deploying to Azure

The Reliable Web App Pattern contains a fully developed reference application that you can use to base your own applications on. We'll use this reference application as part of our workshop today. But first we'll need to provision and deploy the resources.

1. Switch to the **Reference App** folder:

    ```powershell
    cd "Reference App"
    ```

1. We'll use the Azure Developer CLI to deploy the code. You'll first want to create a new PowerShell environment variable and then initialize the **azd** environment. _In this case, your username is only the portion before the `@` in the login credentials._

    ```powershell
    $myEnvironmentName = '<YOUR USERNAME>'
    azd init -e $myEnvironmentName
    ```

1. Now we'll deploy the resources to Azure. This will take about 25 minutes to complete.

    ```powershell
    azd provision
    ```
    > When the prompt appears to select an Azure location, opt for either West US (westus) or East US (eastus).
    
    > We're going to move ahead to the **RWA Overview** lecture portion of the workshop while everybody's machine provisions. Once done, we'll come back and finish the tooling setup.

##### After the provision

1. Because the RWA reference application uses Azure AD resources, we want to create Azure AD application client registrations for the web and API applications. Use the following command:

    ```powershell
    pwsh -c "Set-ExecutionPolicy Bypass Process; .\infra\createAppRegistrations.ps1 -g '$myEnvironmentName-rg'"
    ```

1. Finally we're ready to deploy the code. First we'll set a new **azd** environment variable and then use it to deploy the code:

   ```powershell
    azd env set AZURE_RESOURCE_GROUP "$myEnvironmentName-rg"
    azd deploy
    ```

1. Once everything is deployed, you'll be able to open the Azure portal and view your resource group. It will be named something like `<YOUR USER NAME>-rg`. From there you can open up the Front Door and CDN Profile resource, and browse to the endpoint hostname. Alternatively, you can execute the below script to query the Azure Front Door endpoint from your resource group.

   ```powershell
   pwsh -c "Set-ExecutionPolicy Bypass Process; .\ShowFrontDoorUri.ps1 -ResourceGroupName '$myEnvironmentName-rg'"
   ```

1. Navigate to the `Front Door URI` and click on the **Employee Sign In** situated at the top right corner. Please follow the login process by using the `username` and `password` that were shared with you earlier. Once you're successfully logged in, you can proceed to complete a ticket purchase.

### Local development

Now let's get everything setup so you can run the RWA reference application locally. We'll need get connection strings from Azure and also make Azure firewall changes.

To connect to the database we'll use connection strings from Key Vault and App Configuration Service. Use the following script to retrieve data and store it as User Secrets on your workstation.

1. Open the Visual Studio solution `./Reference App/src/Relecloud.sln`
1. Setup the **Relecloud.Web** project User Secrets
    1. Right-click on the **Relecloud.Web** project
    2. From the context menu choose **Manage User Secrets**
    3. From a command prompt run the command:

        ```powershell
        cd "Reference App"
        pwsh -c "Set-ExecutionPolicy Bypass Process; .\infra\localDevScripts\getSecretsForLocalDev.ps1 -g '$myEnvironmentName-rg' -Web"
        ```

    4. Copy the output into the `secrets.json` file for the **Relecloud.Web** project.    
1. Setup the **Relecloud.Web.Api** project User Secrets
    1. Right-click on the **Relecloud.Web.Api** project
    2. From the context menu choose **Manage User Secrets**
    3. From a command prompt run the command

        ```powershell
        pwsh -c "Set-ExecutionPolicy Bypass Process; .\infra\localDevScripts\getSecretsForLocalDev.ps1 -g '$myEnvironmentName-rg' -Api"
        ```

    4. Copy the output into the `secrets.json` file for the 
    **Relecloud.Web.Api** project.

1. Right-click the **Relecloud** solution and pick **Configure Startup Projects...**
1. Choose **Multiple startup projects**
1. Change the dropdowns for **Relecloud.Web** and **Relecloud.Web.Api** to the action of **Start**.
1. Click **Ok** to close the popup

    ![Configure Startup Projects](./images/multiple-startups.png)

1. Add your IP address to the SQL Database firewall as an allowed connection by using the following script

    ```powershell
    pwsh -c "Set-ExecutionPolicy Bypass Process; .\infra\localDevScripts\addLocalIPToSqlFirewall.ps1 -g '$myEnvironmentName-rg'"
    ```

1. When connecting to Azure SQL database you'll connect with your Azure AD account.
Run the following command to give your Azure AD account permission to access the database.

    ```powershell
    pwsh -c "Set-ExecutionPolicy Bypass Process; .\infra\localDevScripts\makeSqlUserAccount.ps1 -g '$myEnvironmentName-rg'"
    ```

    The script will give you a warning that is about to reset the SQL admin password, press **Enter** to proceed.

1. Back in Visual Studio, open up the **File** menu and select the **Account settings...** option.
1. Under the **All Accounts** heading click **+ Add**, then choose **Microsoft**.
1. Sign in with the credentials you were given for this workshop.
1. Press **F5** to start debugging the application.

   - You may be prompted to trust the _ASP.NET Core SSL certificte_ or the _IIS Express SSL certificate_ during the first run.  Choose **Yes** to trust the certificate.

A web browser window with Swagger tooling and the website front-end should appear.

Now that the tooling is setup, let's look at how you can optimize your costs when building cloud-enabled applications in [the next module](../Part%203%20-%20Cost%20Optimization/README.md).
