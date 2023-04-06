ADO_AGENT_IMAGE := poc/adoagent:1.0

deploy-aks:
	@terraform -chdir=./terraform init
	@terraform -chdir=./terraform apply -auto-approve

deploy-prom-stack:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm --kubeconfig ./terraform/kubeconfig upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack --wait --version 45.7.1 --namespace kube-prometheus-stack --create-namespace --set grafana.defaultDashboardsEnabled=false

deploy-keda:
	helm repo add kedacore https://kedacore.github.io/charts
	helm repo update
	helm --kubeconfig ./terraform/kubeconfig upgrade --install keda kedacore/keda --wait --version 2.9.4 --namespace keda --create-namespace

create-ado-agent-image:
	docker build -t "$(shell terraform -chdir=./terraform output -raw acr_url)/$(ADO_AGENT_IMAGE)" ./agent/docker/base/
	@docker login \
    	$(shell terraform -chdir=./terraform output -raw acr_url) \
    	-u $(shell terraform -chdir=./terraform output -raw acr_user) \
    	-p $(shell terraform -chdir=./terraform output -raw acr_pass)

	docker push "$(shell terraform -chdir=./terraform output -raw acr_url)/$(ADO_AGENT_IMAGE)"

deploy-ado-agent-job:
	helm --kubeconfig ./terraform/kubeconfig upgrade --install --wait --namespace ado-agent-default --create-namespace \
		ado-default-agent ./agent/chart/ado-agent \
		-f ./agent/pool/values.yaml \
		--set image.repository="$(shell terraform -chdir=./terraform output -raw acr_url)/$(ADO_AGENT_IMAGE)"

add-grafana-dashboard:
	 kubectl --kubeconfig ./terraform/kubeconfig apply -f dashboard/cluster-scale-overview.yaml

expose-grafana:
	kubectl --kubeconfig ./terraform/kubeconfig -n kube-prometheus-stack port-forward service/kube-prometheus-stack-grafana 65480:80

destroy-all:
	@terraform -chdir=./terraform destroy -auto-approve