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
        stage("static_test"){
            agent{ docker{ image 'mobiarm'; args "-u root --entrypoint=''" } }
            steps{
                sh '''#!/bin/bash
                set +e
                rm -rf static-report && mkdir -p static-report

                # C++ — ROS headers aren't on the include path here, so suppress those
                cppcheck --enable=warning,performance,portability \
                        --inline-suppr --inconclusive \
                        --suppress=missingInclude --suppress=missingIncludeSystem \
                        --xml --xml-version=2 \
                        src/main_nodes/src \
                        2> static-report/cppcheck.xml

                # Python — launch files, scan filters, tests
                flake8 src tests --max-line-length=120 --exclude=__pycache__ \
                    --format=pylint --output-file=static-report/flake8.txt --exit-zero

                # Dockerfile
                hadolint -f json Dockerfile > static-report/hadolint.json

                # XML/xacro well-formedness — catches a broken URDF before Gazebo does
                find src \\( -name '*.xml' -o -name '*.xacro' -o -name '*.srdf' \\) \
                    -print0 | xargs -0 -r xmllint --noout
                '''
                recordIssues(
                    enabledForFailure: true,
                    tools: [
                        cppCheck(pattern: 'static-report/cppcheck.xml'),
                        flake8(pattern: 'static-report/flake8.txt'),
                        hadoLint(pattern: 'static-report/hadolint.json')
                    ],
                    qualityGates: [
                        [threshold: 1,  type: 'TOTAL_ERROR', unstable: true],
                        [threshold: 30, type: 'TOTAL_HIGH',  unstable: true]
                    ]
                )
                archiveArtifacts artifacts: 'static-report/**', allowEmptyArchive: true
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
        failure{echo "pipeline failure"}
        success{echo "pipeline success"}
    }
}