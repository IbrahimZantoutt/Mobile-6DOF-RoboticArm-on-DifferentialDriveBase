@Library('Global-Shared-Lib') _

def generateTag(branch,buildNum){
    return "${branch}-${buildNum}"
}

pipeline{
    agent none
    parameters{
        choice(name:"ActionType",choices:["noPush","push"], description:"push or dont push the image")
    }
    stages{
        stage("announce"){
            agent any
            steps{
                sh'echo "branch: $BRANCH_NAME"'
            }
        }
        stage("build image"){
            agent any
            when{
                changeset 'Dockerfile'
            }
            options{
                timeout(time:20,unit:"MINUTES")
            }
            steps{
                sh'docker build -t mobiarm .'
            }
        }
        stage("parallel build stage"){
            parallel{
                stage("ros2 stage"){
                    agent{docker{image 'mobiarm'}}
                    steps{
                        sh'''#!/bin/bash
                        source /opt/ros/humble/setup.bash
                        colcon build
                        '''

                        archiveArtifacts artifacts: "build/**", allowEmptyArchive:true
                    }
                }
                stage("py stage") {
                    agent { docker { image 'python:3.12' } }
                    steps {
                        script {
                            try {
                                sh '''
                                rm -rf report
                                mkdir -p report
                                pip install pytest --break-system-packages
                                pytest tests/ --junitxml=report/results.xml
                                '''
                            }
                            catch (Exception e) {
                                echo "caught exception while running tests: ${e.getMessage()}"
                                currentBuild.result = "UNSTABLE"
                            }
                        }
                        junit "report/results.xml"
                        archiveArtifacts artifacts: "report/**", allowEmptyArchive: true
                        script {
                            def map = [vision_node: true, arm_controller: false, nav_stack: true]
                            def mapFilt = map.findAll { key, value -> value == true }
                            echo mapFilt.toString()
                        }
                    }
                }
            }
        }
        stage("push stage"){
            agent any
            when{
                allOf{
                    branch 'main'
                    expression{params.ActionType == "push"}
                }
            }
            steps{
                script{
                    env.IMAGE_TAG = generateTag(env.BRANCH_NAME,env.BUILD_NUMBER)
                }
                TagPushDockerImage("mobiarm",env.IMAGE_TAG,"tokenDocker")
            }
        }
    }
    post{
        always{echo "running pipeline"}
        failure{
            slackSend(channel: '#ci-builds', color: 'danger', message: "Build failed in ${env.JOB_NAME} - ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
        }
        success{
            slackSend(channel: '#ci-builds', color: 'good', message: "Build succeeded in ${env.JOB_NAME} - ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
        }
    }
}