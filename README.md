## Usage

These chef cookbooks are designed (so far) for use with scalarium to get a jenkins server setup on AWS.

1. Setup a new **cloud**
2. Setup a new application (no deployable asset)
3. Add this repo as the custom cookbooks URL.
4. Define custom JSON.
5. Create an instance
6. Add custom deploy recipe `jenkins::default`
7. Update cookbooks
8. Deploy
9. Configure SSH (see below)
10. Configure DNS
11. Test!

```json
{
  "jenkins": {
    "http_proxy": {
      "variant": "apache2",
      "host_name": "jenkins.domain.com"
    },
    "hipchat": {
      "token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "room": "My Room"
    },
    "jobs": {
      "config_url": "http://some.domain.com/path"
    }
  }
}
````

## SSH Configuration

The only manual step required is to login to the server and get the ssh key that was generated and upload it to your deploy user's account on github.

    ssh my-server
    cd /var/lib/jenkins/.ssh
    cat id_rsa.pub
    # add to github
    ssh -vT git@github.com

After that you will need to get the DNS address provided by AWS from the scalarium instance page and configure your **host_name** to point to there.

## Job Configuration

`node[:jenkins][:jobs][:config_url]` is to allow an endpoint for configuring jenkins jobs. Your endpoint should be configured like the following

    http://mydomain.com/jenkinsconfig

this is interpolated in the default recipe for jobs configured and fetched from the full url like

    http://mydomain.com/jenkinsconfig/:project.xml


## Useful Links

* http://reefpoints.dockyard.com/ruby/2012/03/05/our-ci-setup.html
* https://github.com/nicksieger/ci_reporter
* http://blog.knuthaugen.no/2011/04/continuous-delivery-ii-smoketests-in-ruby-and-rails.html
* http://yakiloo.com/setup-jenkins-and-rvm/
* http://hron.me/jenkins-rvm-bundler
* http://www.howtogeek.com/howto/ubuntu/install-mysql-server-5-on-ubuntu/
* http://timvoet.com/2011/05/19/jenkins-rails-code-coverage-a-gotcha/
* https://wiki.jenkins-ci.org/display/JENKINS/Ruby+metrics+plugin
* https://wiki.jenkins-ci.org/display/JENKINS/Starting+and+Accessing+Jenkins
* https://wiki.jenkins-ci.org/display/JENKINS/Github+OAuth+Plugin
* https://github.com/fnichol/chef-jenkins
* https://github.com/fabn/rails-jenkins-template