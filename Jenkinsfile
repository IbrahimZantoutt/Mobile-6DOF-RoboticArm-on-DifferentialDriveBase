
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
                        sh'''
                        #!/bin/bash
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
                withCredentials([usernamePassword(
                    credentialsId: 'tokenDocker',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]){
                    sh'''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker tag python:3.12 $DOCKER_USER/python-test-pipeline:latest
                    '''
                }
                retry(2){
                    sh'''
                    docker push $DOCKER_USER/python-test-pipeline:latest
                    '''
                }
            }

        }

    }
    post{
        always{echo "running pipeline"}
        failure{echo "pipeline failed"}
        success{echo "pipeline ran successfully"}
    }


}