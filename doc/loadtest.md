# Set up JMeter to do load testing on the windows client machine

Connect to the windows client machine

## How to connect
First let's init the variables!

`source 01init.sh`

Connect to the jumpbox:

`ssh rhel@$jumpbox`

Connect to wcli0 thru an ssh tunnel:

`ssh -L 127.0.0.1:3390:192.168.0.40:3389 rhel@$jumpbox`

then use RDP to connect to 127.0.0.1:3390 and log in 

## Install JMeter

1. **Install Java Runtime**
  
    JMeter requires Java 8 or 9 so Install Java runtime from https://java.com/en/download/

2. **Install IBM JDBC drivers**

3. **Install Apache JMeter** 
  
    http://jmeter.apache.org/

  - Select *Download Releases* in the menu on the left
  - In the *Binaries* section, download apache-jmeter-5.0.zip
  - There is no installer for JMeter, you can just extract the zip into a folder on the machine e.g. `c:\JMeter`


4. **Copy the JDBC driver to the JMeter lib folder**

    copy `C:\Program Files\IBM\IBM DATA SERVER DRIVER\java\db2jcc.jar` to the JMeter lib folder e.g. `c:\JMeter\lib`

5. **Launch JMeter**

    Navigate to the `c:\JMeter\bin` folder and run `JMeter.bat` to launch JMeter

6. **Create a thread group**

    Right-click on Test Plan in the tree on the left

    Select: **`Add->Threads (Users)->Thread group`**

    Fill in these fields:
    
    | Field | Value |
    | ----------- | ----------- |
    | Number of threads (users) | 50 |
    | Ramp-Up Period (in seconds) | 1 | 
    | Loop Count | 1000 |


7. **Add a connection**

    Right-click on the Thread group element in the tree on the left

    Select: **`Add->Config Element->JDBC Connection Configuration`**

    Fill in these fields:

    | Field | Value |
    | ------ | ----- |
    | Variable name for created Pool | myDB |
    | Validation Query | select 1 from sysibm.sysdummy1 |
    | Database URL | jdbc:db2://192.168.0.20:50000/my-db-name |
    | JDBC Driver class | com.ibm.db2.jcc.DB2Driver |
    | Username | db2sdin1 |
    | Password | BYlcxdcm02_____ |


8. **Add one or more Queries to test**

    Right-click on the Thread group element in the tree on the left

    Select: `Add -> Sampler -> JDBC Request`

    Fill in these fields:
    
    | Field | Value |
    | ------ | ----- |
    | Variable name of Pool declared in JDBC Connection Configuration | myDB |
    | SQL Query | select * from mytablename |

    Repeat step 8 for each query that is part of your test

9. **Add one or more listeners to show the test output**

    There are different types of listener that you can explore. 

    For this example, we will add the following listeners:

    Right-click on the Thread group element in the tree on the left
    - Select: `Add->Listener->Graph Results`
    - Select: `Add->Listener->View Results Tree`
    - Select: `Add->Listener->Summary Report`

10. **Run the test**

    Click on the *Start* icon on the toolbar or press `Ctrl-R`

    The test runs - as it executes, you can see the threads increment on the right side of the toolbar.

    Once the test in complete, click on each of the listener nodes that you created to observe the results.

    Now that you have a working test, you can also observe the impact of running tests on the monitoring machine.
