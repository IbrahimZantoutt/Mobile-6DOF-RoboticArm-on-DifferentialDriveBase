
pipeline {
    agent none
    parameters{
        choice(name:"TargetStage",choices:["build","pytest","both","bothWithImgPush"],description:"choose which stage tp run")
    }
    stages {
        stage("parrallel build"){
            parallel{
                stage("build") {
                    when{expression{params.TargetStage in ["build", "both", "bothWithImgPush"]}}
                    agent { docker { image 'mobiarm' } }
                    steps {
                        sh '''#!/bin/bash
                            source /opt/ros/humble/setup.bash
                            colcon build
                        '''
                    }
                }
                stage("pytest") {
                    when{expression{params.TargetStage in ["pytest", "both", "bothWithImgPush"]}}
                    agent { docker { image 'python:3.12' } }
                    steps {
                        sh 'echo "testing python"'
                    }
                }
            }
        }
        stage("push image"){
            when{expression{params.TargetStage == "bothWithImgPush"}}
            agent any
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'tokenDocker',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]){
                    sh'''
                     echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                     docker tag python:3.12 $DOCKER_USER/python-test-pipeline:latest
                     docker push $DOCKER_USER/python-test-pipeline:latest
                    '''
                }
            }
        }

    }
    post {
        always { echo "ran the pipeline" }
        success { echo "pipeline succeeded" }
        failure { echo "pipeline failed" }
    }
}
