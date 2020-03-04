//Jenkinsfile
import groovy.json.JsonOutput
//git env vars
env.git_url = 'https://sumitroop@bitbucket.org/sumitroop/jenkins.git'
env.git_branch = 'master'
env.credentials_id = '1'
//slack env vars
env.slack_url = 'https://inquisitivemind.slack.com/services/BU5CGM6EL'
env.notification_channel = 'devops'
//jenkins env vars
env.jenkins_server_url = 'http://35.200.254.36:8080/'
env.jenkins_node_custom_workspace_path = "/opt/bitnami/apps/jenkins/jenkins_home/${JOB_NAME}/workspace"
env.jenkins_node_label = 'master'
env.terraform_version = '0.12.21'
def notifySlack(text, channel, attachments) {
    def payload = JsonOutput.toJson([text: text,
        channel: channel,
        username: "Jenkins",
        attachments: attachments
    ])
    sh "export PATH=/opt/bitnami/common/bin:$PATH && curl -X POST --data-urlencode \'payload=${payload}\' ${slack_url}"
}
pipeline {
agent {
node {
customWorkspace "$jenkins_node_custom_workspace_path"
label "$jenkins_node_label"
} 
}
stages {
stage('fetch_latest_code') {
steps {
git branch: "$git_branch" ,
credentialsId: "$credentials_id" ,
url: "$git_url"
}
}
withAws(credentials: 'aws-credentials') {
   sh 'env'
   sh 'aws sts get-caller-identity'
}
stage('install_deps') {
steps {
sh "sudo apt install wget zip python-pip -y"
sh "cd /tmp"
sh "curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb"
sh "sudo apt install ./keybase_amd64.deb"
sh "sudo run_keybase"
sh "curl -o terraform.zip https://releases.hashicorp.com/terraform/'$terraform_version'/terraform_'$terraform_version'_linux_amd64.zip"
sh "unzip terraform.zip"
sh "sudo mv terraform /usr/bin"
sh "rm -rf terraform.zip"
sh "rm -rf keybase_amd64.deb"
}
}
stage('init_and_plan') {
steps {
sh "sudo terraform init $jenkins_node_custom_workspace_path/workspace"
sh "sudo terraform plan $jenkins_node_custom_workspace_path/workspace"
notifySlack("Build completed! Build logs from jenkins server $jenkins_server_url/jenkins/job/$JOB_NAME/$BUILD_NUMBER/console", notification_channel, [])
}
}
stage('approve') {
steps {
  notifySlack("Do you approve deployment? $jenkins_server_url/jenkins/job/$JOB_NAME", notification_channel, [])
input 'Do you approve deployment?'
}
}
stage('apply_changes') {
steps {
sh "echo 'yes' | sudo terraform apply $jenkins_node_custom_workspace_path/workspace"
notifySlack("Deployment logs from jenkins server $jenkins_server_url/jenkins/job/$JOB_NAME/$BUILD_NUMBER/console", notification_channel, [])
}
}
}
post { 
  always { 
    cleanWs()
   }
   }