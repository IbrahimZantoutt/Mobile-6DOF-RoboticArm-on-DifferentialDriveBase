@Library('Global-Shared_Lib')

pipeline{
    agent none
    parameters{
        choice(name:"ActionType", choices:["noPush","pushImage"] ,description:"choose whether to push image or not")
    }
    stages{
        stage("branch print"){
            agent any
            steps{
                sh'echo "in branch: $BRANCH_NAME"'
            }
        }
        stage("build image"){
            agent any
            when{
                changeset "Dockerfile"
            }
            options{
                timeout(time:20,unit:"MINUTES")
            }
            steps{
                sh'''
                docker build -t mobiarm .
                '''
            }
        }
        stage("run parallel"){
            parallel{
                stage("ros2 stage"){
                    agent{docker{image 'mobiarm'}}
                    steps{
                        sh'''#!/bin/bash
                        source /opt/ros/humble/setup.bash
                        colcon build
                        ''' 

                        archiveArtifacts artifacts: 'build/**', allowEmptyArchive: true
                    }
                }

                stage("py stage"){
                    agent{docker{image 'python:3.12'}}
                    steps{
                        sh'''
                        mkdir -p report
                        echo "python stage ran" > report/logFile.txt
                        '''

                        archiveArtifacts artifacts: "report/**", allowEmptyArchive: true
                    }
                }
            }
        }
        stage("push stage"){
            agent any
            when{
                allOf{
                    branch 'main'
                    expression{params.ActionType == "pushImage"}
                }
            }
            steps{
                script{
                    try{
                        def tag = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                        env.IMAGE_TAG=tag
                        sh'exit 1'
                    }
                    catch (Exception e){
                        echo "Caught exception: ${e.getMessage()}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
                TagPushDockerImage("mobiarm",env.IMAGE_TAG,"tokenDocker")
            }

        }

    }
    post{
        always{echo "running pipeline"}
        failure{echo "pipeline failed"}
        success{echo "pipeline ran successfully"}
    }


}