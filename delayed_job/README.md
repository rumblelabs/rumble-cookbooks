## Delayed Job

Chef cookbooks for delayed_job

1. Setup a new **cloud**
2. Setup a new application
3. Add this repo as the custom cookbooks URL.
4. Define custom JSON.
5. Create a "workers" role (blank)
6. Create an instance
7. Add custom configure reciple `rails::configure, god::default`
8. Add custom deploy recipe `deploy::rails, god::delayed_job, delayed_job::deploy`
9. Start instance (or update cookbooks)
11. Configure SSH (see below)
10. Deploy


## SSH Configuration

The only manual step required is to login to the server and get the ssh key that was generated and upload it to your deploy user's account on github.

    ssh my-server
    su deploy
    cd ~/.ssh
    ssh-keygen
    cat id_rsa.pub
    # add to github and test
    ssh -vT git@github.com
    # add to heroku
    heroku keys:add ~/.ssh/id_rsa.pub

