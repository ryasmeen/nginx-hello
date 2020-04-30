pipeline {
  environment {
    registry = "ryasmeen/nginx-hello"
    registryCredential = 'docker-hub-credentials'
    dockerImage = ''
    CHECK_URL_DEV = "http://192.168.1.234:8001"
    CMD_DEV = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL_DEV}"
    CHECK_URL_PROD = "http://192.168.1.235:8001"
    CMD_PROD = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL_PROD}"
    webAppResourceGroup = 'ryasmeen-linux-rg'
    webAppResourcePlan = 'ryasmeen-app-service-plan'
    webAppName = 'myweb-nginx'
    imageName = 'myweb-nginx'
    imageWithTag = '1.0'
  }
  agent any
  stages {
    stage('Cloning Git Repo') {
      steps {
        git 'https://github.com/ryasmeen/nginx-hello.git'
      }
    }
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build registry + ":1.0"
        }
      }
    }
    /* stage('Test image') {
     Testing using goss
      steps {
        script {
          sh 'dgoss run ryasmeen/nginx-hello:latest'
        }
      }
    } */
    stage('Push - Deploy Image') {
      steps {
        script {
          docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
        stage ('Deploy To Dev') {
                steps {
                        script {
                                sshagent (credentials: ['caas-master-ssh-key']) {
                                        sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen 192.168.1.234 uptime'
                                        sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen 192.168.1.234 sudo docker rm -f ${webAppName}'
                                        sh 'ssh -o StrictHostKeyChecking=no -l ryasmeen 192.168.1.234 sudo docker run -d --name ${webAppName} -it -p 8001:80 ${registry}:latest'
                                }
            }
        }
    }

        stage('Test Dev') {
                steps {
                        script{
                                // sh "curl --write-out %{http_code} --silent --output /dev/null http://192.168.1.234:8001 > commandResult"
                                sh "${CMD_DEV} > commandResult"
                                env.status = readFile('commandResult').trim()
                                sh "echo ${env.status}"
                                if (env.status == '200') {
                                                currentBuild.result = "SUCCESS"
                                }
                                else {
                                                currentBuild.result = "FAILURE"
                                }
                        }
                }
        }

    stage ('Deploy To Prod') {
                steps {
                        script {
                                sshagent (credentials: ['podman-master-ssh-key']) {
                                        sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 192.168.1.235 uptime'
                                        sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 192.168.1.235 sudo docker rm -f ${webAppName}'
                                        sh 'ssh -o StrictHostKeyChecking=no -l amohamm2 192.168.1.235 sudo docker run -d --name ${webAppName}' -it -p 8001:80 ${registry}:latest'
                                }
            }
        }
    }

        stage('Test Prod') {
                steps {
                        script{
                                // sh "curl --write-out %{http_code} --silent --output /dev/null http://192.168.1.235:8001 > commandResult"
                                sh "${CMD_PROD} > commandResult"
                                env.status = readFile('commandResult').trim()
                                sh "echo ${env.status}"
                                if (env.status == '200') {
                                                currentBuild.result = "SUCCESS"
                                }
                                else {
                                                currentBuild.result = "FAILURE"
                                }
                        }
                }
        }

        stage('Deploy to Azure') {
				steps {
						script{
								// login Azure
								withCredentials([azureServicePrincipal('<mySrvPrincipal>')]) {
								sh '''
								az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
								az account set -s $AZURE_SUBSCRIPTION_ID
								'''
								sh "az webapp create -g {webAppResourceGroup} -p ${webAppResourcePlan} -n ${webAppName} -i ${registry}:${imageWithTag}"
								}
							}
					}
			}
		}
	}
}
