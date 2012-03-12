maintainer        "Peritor GmbH"
maintainer_email  "scalarium@peritor.com"
license           "Apache 2.0"
description       "Sets up delayed_job to run its workers"
version           "0.1"
recipe            "delayed_job::deploy", "Sets up the cron job to run the DJ workers. Assumes the package is installed as gem or plugin."

supports 'ubuntu'
