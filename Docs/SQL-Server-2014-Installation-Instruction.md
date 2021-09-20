This page will guide you on how to perform a new SQL Server 2014 standard edtion installation.

SQL Server 2014 can be downloaded from share drive - S:\IT\MSDN\SQL 2014 Full Version\

**Operating Systems Requirements**
* Do no try to install SQL Server 2014 on a compressed, encrypted or read-only drive, because setup will block the installation.
* Do not install SQL Server on a Domain Controller. 
* Verify Windows Management Instrumentation service is running.
* Configure your firewall to allow SQL Server access. 
* The user account that is running SQL Server Setup must have administrative privileges on the computer.
* At least 6.0 GB of disk space are required by SQL Server setup.

**Step-by-step procedure to install SQL Server 2014:**

Go to share drive: S:\IT\MSDN\SQL 2014 Full Version\, copy to your local machine or directly run SQL Server 2014 setup from share drive. 
![step1](https://cloud.githubusercontent.com/assets/1993543/12889474/05d000d6-ce4d-11e5-8b42-885fd2b84689.png)

On the following screen, make a click on the "Installation" hyperlink in the left side of the screen, and   select the first type available "New SQL Server stand-alone installation or add features to an existing installation".
![step2](https://cloud.githubusercontent.com/assets/1993543/12889587/9c85f97c-ce4d-11e5-8897-bf0acce0af80.png)

Then enter a product key provided on screen below, to installing a licensed edition of SQL Server.
![step3](https://cloud.githubusercontent.com/assets/1993543/12889613/be98a1ae-ce4d-11e5-8a93-e4d71c6db883.png)

On the License Terms page,  check the "I accept the license terms" check box, and then click the Next button.
![step4](https://cloud.githubusercontent.com/assets/1993543/12889618/c1f8a704-ce4d-11e5-876a-d9afc8ae3339.png)

On the SQL Server Setup page shown below, to install specific features of SQL Server, click next.
![step5](https://cloud.githubusercontent.com/assets/1993543/12889621/c6a241e8-ce4d-11e5-8424-7459fcf673f0.png)

On the Feature Selection page, select the features you would like to install. A description of each feature will appear on the "Feature description" area when you click on a feature. Once you have selected the features to install, please click on the "Next" button.
![step6](https://cloud.githubusercontent.com/assets/1993543/12889625/cf5ecebe-ce4d-11e5-85e3-29a4db5c3bf0.png)

On the following Instance Configuration page, select a default or named instance for your installation; then click next.
![step7](https://cloud.githubusercontent.com/assets/1993543/12889631/d662c5e4-ce4d-11e5-94e7-159cce243dbe.png)

On the "Server Configuration" page you can also select how you want to start this service on the computer (Startup Type as below settings; then click next.
![step8](https://cloud.githubusercontent.com/assets/1993543/12889639/dbe10670-ce4d-11e5-80e1-75020237c81d.png)

On the Database Engine Configuration page below, choose the Mixed Mode to use for your SQL Server installation.  Also setup creates an sa account. Then click next.
![step9](https://cloud.githubusercontent.com/assets/1993543/12889643/e0107d98-ce4d-11e5-9906-483d08648db0.png)

On the "Complete" page below, to view the Setup summary log by clicking the blue link provided on the bootom this page. To exit the SQL Server Installation Wizard, click Close.
![step10](https://cloud.githubusercontent.com/assets/1993543/12889648/e6205f00-ce4d-11e5-9dcc-f3a7e243512d.png)
