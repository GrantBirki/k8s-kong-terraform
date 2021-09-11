resource "kubernetes_manifest" "serviceaccount_monitoring_prometheus_kube_state_metrics" {
  manifest = {
    "apiVersion" = "v1"
    "imagePullSecrets" = []
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "prometheus"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "helm.sh/chart" = "kube-state-metrics-3.4.2"
      }
      "name" = "prometheus-kube-state-metrics"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_monitoring_prometheus_alertmanager" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "annotations" = {}
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "alertmanager"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-alertmanager"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_monitoring_prometheus_node_exporter" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "annotations" = {}
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "node-exporter"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-node-exporter"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_monitoring_prometheus_pushgateway" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "annotations" = {}
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "pushgateway"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-pushgateway"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_monitoring_prometheus_server" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "annotations" = {}
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "server"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-server"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "configmap_monitoring_prometheus_alertmanager" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "alertmanager.yml" = <<-EOT
      global: {}
      receivers:
      - name: default-receiver
      route:
        group_interval: 5m
        group_wait: 10s
        receiver: default-receiver
        repeat_interval: 3h
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "alertmanager"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-alertmanager"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "configmap_monitoring_prometheus_server" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "alerting_rules.yml" = <<-EOT
      {}
      
      EOT
      "alerts" = <<-EOT
      {}
      
      EOT
      "prometheus.yml" = <<-EOT
      global:
        evaluation_interval: 1m
        scrape_interval: 10s
        scrape_timeout: 10s
      rule_files:
      - /etc/config/recording_rules.yml
      - /etc/config/alerting_rules.yml
      - /etc/config/rules
      - /etc/config/alerts
      scrape_configs:
      - job_name: prometheus
        static_configs:
        - targets:
          - localhost:9090
      - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        job_name: kubernetes-apiservers
        kubernetes_sd_configs:
        - role: endpoints
        relabel_configs:
        - action: keep
          regex: default;kubernetes;https
          source_labels:
          - __meta_kubernetes_namespace
          - __meta_kubernetes_service_name
          - __meta_kubernetes_endpoint_port_name
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
      - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        job_name: kubernetes-nodes
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - replacement: kubernetes.default.svc:443
          target_label: __address__
        - regex: (.+)
          replacement: /api/v1/nodes/$1/proxy/metrics
          source_labels:
          - __meta_kubernetes_node_name
          target_label: __metrics_path__
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
      - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
        job_name: kubernetes-nodes-cadvisor
        kubernetes_sd_configs:
        - role: node
        relabel_configs:
        - action: labelmap
          regex: __meta_kubernetes_node_label_(.+)
        - replacement: kubernetes.default.svc:443
          target_label: __address__
        - regex: (.+)
          replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor
          source_labels:
          - __meta_kubernetes_node_name
          target_label: __metrics_path__
        scheme: https
        tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: true
      - job_name: kubernetes-service-endpoints
        kubernetes_sd_configs:
        - role: endpoints
        relabel_configs:
        - action: keep
          regex: true
          source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_scrape
        - action: replace
          regex: (https?)
          source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_scheme
          target_label: __scheme__
        - action: replace
          regex: (.+)
          source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_path
          target_label: __metrics_path__
        - action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          source_labels:
          - __address__
          - __meta_kubernetes_service_annotation_prometheus_io_port
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - action: replace
          source_labels:
          - __meta_kubernetes_namespace
          target_label: kubernetes_namespace
        - action: replace
          source_labels:
          - __meta_kubernetes_service_name
          target_label: kubernetes_name
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_node_name
          target_label: kubernetes_node
      - job_name: kubernetes-service-endpoints-slow
        kubernetes_sd_configs:
        - role: endpoints
        relabel_configs:
        - action: keep
          regex: true
          source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_scrape_slow
        - action: replace
          regex: (https?)
          source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_scheme
          target_label: __scheme__
        - action: replace
          regex: (.+)
          source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_path
          target_label: __metrics_path__
        - action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          source_labels:
          - __address__
          - __meta_kubernetes_service_annotation_prometheus_io_port
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - action: replace
          source_labels:
          - __meta_kubernetes_namespace
          target_label: kubernetes_namespace
        - action: replace
          source_labels:
          - __meta_kubernetes_service_name
          target_label: kubernetes_name
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_node_name
          target_label: kubernetes_node
        scrape_interval: 5m
        scrape_timeout: 30s
      - honor_labels: true
        job_name: prometheus-pushgateway
        kubernetes_sd_configs:
        - role: service
        relabel_configs:
        - action: keep
          regex: pushgateway
          source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_probe
      - job_name: kubernetes-services
        kubernetes_sd_configs:
        - role: service
        metrics_path: /probe
        params:
          module:
          - http_2xx
        relabel_configs:
        - action: keep
          regex: true
          source_labels:
          - __meta_kubernetes_service_annotation_prometheus_io_probe
        - source_labels:
          - __address__
          target_label: __param_target
        - replacement: blackbox
          target_label: __address__
        - source_labels:
          - __param_target
          target_label: instance
        - action: labelmap
          regex: __meta_kubernetes_service_label_(.+)
        - source_labels:
          - __meta_kubernetes_namespace
          target_label: kubernetes_namespace
        - source_labels:
          - __meta_kubernetes_service_name
          target_label: kubernetes_name
      - job_name: kubernetes-pods
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - action: keep
          regex: true
          source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_scrape
        - action: replace
          regex: (https?)
          source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_scheme
          target_label: __scheme__
        - action: replace
          regex: (.+)
          source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_path
          target_label: __metrics_path__
        - action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          source_labels:
          - __address__
          - __meta_kubernetes_pod_annotation_prometheus_io_port
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - action: replace
          source_labels:
          - __meta_kubernetes_namespace
          target_label: kubernetes_namespace
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_name
          target_label: kubernetes_pod_name
        - action: drop
          regex: Pending|Succeeded|Failed|Completed
          source_labels:
          - __meta_kubernetes_pod_phase
      - job_name: kubernetes-pods-slow
        kubernetes_sd_configs:
        - role: pod
        relabel_configs:
        - action: keep
          regex: true
          source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_scrape_slow
        - action: replace
          regex: (https?)
          source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_scheme
          target_label: __scheme__
        - action: replace
          regex: (.+)
          source_labels:
          - __meta_kubernetes_pod_annotation_prometheus_io_path
          target_label: __metrics_path__
        - action: replace
          regex: ([^:]+)(?::\d+)?;(\d+)
          replacement: $1:$2
          source_labels:
          - __address__
          - __meta_kubernetes_pod_annotation_prometheus_io_port
          target_label: __address__
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - action: replace
          source_labels:
          - __meta_kubernetes_namespace
          target_label: kubernetes_namespace
        - action: replace
          source_labels:
          - __meta_kubernetes_pod_name
          target_label: kubernetes_pod_name
        - action: drop
          regex: Pending|Succeeded|Failed|Completed
          source_labels:
          - __meta_kubernetes_pod_phase
        scrape_interval: 5m
        scrape_timeout: 30s
      alerting:
        alertmanagers:
        - kubernetes_sd_configs:
            - role: pod
          tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          relabel_configs:
          - source_labels: [__meta_kubernetes_namespace]
            regex: monitoring
            action: keep
          - source_labels: [__meta_kubernetes_pod_label_app]
            regex: prometheus
            action: keep
          - source_labels: [__meta_kubernetes_pod_label_component]
            regex: alertmanager
            action: keep
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_probe]
            regex: .*
            action: keep
          - source_labels: [__meta_kubernetes_pod_container_port_number]
            regex: "9093"
            action: keep
      
      EOT
      "recording_rules.yml" = <<-EOT
      {}
      
      EOT
      "rules" = "{}"
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "server"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-server"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "persistentvolumeclaim_monitoring_prometheus_alertmanager" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolumeClaim"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "alertmanager"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-alertmanager"
      "namespace" = "monitoring"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "resources" = {
        "requests" = {
          "storage" = "2Gi"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "persistentvolumeclaim_monitoring_prometheus_server" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolumeClaim"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "server"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-server"
      "namespace" = "monitoring"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "resources" = {
        "requests" = {
          "storage" = "8Gi"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "clusterrole_prometheus_kube_state_metrics" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "prometheus"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "helm.sh/chart" = "kube-state-metrics-3.4.2"
      }
      "name" = "prometheus-kube-state-metrics"
    }
    "rules" = [
      {
        "apiGroups" = [
          "certificates.k8s.io",
        ]
        "resources" = [
          "certificatesigningrequests",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "batch",
        ]
        "resources" = [
          "cronjobs",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "apps",
        ]
        "resources" = [
          "daemonsets",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "apps",
        ]
        "resources" = [
          "deployments",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "endpoints",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "autoscaling",
        ]
        "resources" = [
          "horizontalpodautoscalers",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "networking.k8s.io",
        ]
        "resources" = [
          "ingresses",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "batch",
        ]
        "resources" = [
          "jobs",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "limitranges",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "admissionregistration.k8s.io",
        ]
        "resources" = [
          "mutatingwebhookconfigurations",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "namespaces",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "networking.k8s.io",
        ]
        "resources" = [
          "networkpolicies",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "persistentvolumeclaims",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "persistentvolumes",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "policy",
        ]
        "resources" = [
          "poddisruptionbudgets",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "apps",
        ]
        "resources" = [
          "replicasets",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "replicationcontrollers",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "resourcequotas",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "secrets",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "services",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "apps",
        ]
        "resources" = [
          "statefulsets",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "storage.k8s.io",
        ]
        "resources" = [
          "storageclasses",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "admissionregistration.k8s.io",
        ]
        "resources" = [
          "validatingwebhookconfigurations",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "storage.k8s.io",
        ]
        "resources" = [
          "volumeattachments",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_prometheus_alertmanager" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "alertmanager"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-alertmanager"
    }
    "rules" = []
  }
}

resource "kubernetes_manifest" "clusterrole_prometheus_pushgateway" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "pushgateway"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-pushgateway"
    }
    "rules" = []
  }
}

resource "kubernetes_manifest" "clusterrole_prometheus_server" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "server"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-server"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
          "nodes/proxy",
          "nodes/metrics",
          "services",
          "endpoints",
          "pods",
          "ingresses",
          "configmaps",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "networking.k8s.io",
        ]
        "resources" = [
          "ingresses/status",
          "ingresses",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "nonResourceURLs" = [
          "/metrics",
        ]
        "verbs" = [
          "get",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_prometheus_kube_state_metrics" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "prometheus"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "helm.sh/chart" = "kube-state-metrics-3.4.2"
      }
      "name" = "prometheus-kube-state-metrics"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "prometheus-kube-state-metrics"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-kube-state-metrics"
        "namespace" = "monitoring"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_prometheus_alertmanager" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "alertmanager"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-alertmanager"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "prometheus-alertmanager"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-alertmanager"
        "namespace" = "monitoring"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_prometheus_pushgateway" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "pushgateway"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-pushgateway"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "prometheus-pushgateway"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-pushgateway"
        "namespace" = "monitoring"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_prometheus_server" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "server"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-server"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "prometheus-server"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "prometheus-server"
        "namespace" = "monitoring"
      },
    ]
  }
}

resource "kubernetes_manifest" "service_monitoring_prometheus_kube_state_metrics" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "app.kubernetes.io/instance" = "prometheus"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "helm.sh/chart" = "kube-state-metrics-3.4.2"
      }
      "name" = "prometheus-kube-state-metrics"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "http"
          "port" = 8080
          "protocol" = "TCP"
          "targetPort" = 8080
        },
      ]
      "selector" = {
        "app.kubernetes.io/instance" = "prometheus"
        "app.kubernetes.io/name" = "kube-state-metrics"
      }
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "service_monitoring_prometheus_alertmanager" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "alertmanager"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-alertmanager"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "http"
          "port" = 80
          "protocol" = "TCP"
          "targetPort" = 9093
        },
      ]
      "selector" = {
        "app" = "prometheus"
        "component" = "alertmanager"
        "release" = "prometheus"
      }
      "sessionAffinity" = "None"
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "service_monitoring_prometheus_node_exporter" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/scrape" = "true"
      }
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "node-exporter"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-node-exporter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "clusterIP" = "None"
      "ports" = [
        {
          "name" = "metrics"
          "port" = 9100
          "protocol" = "TCP"
          "targetPort" = 9100
        },
      ]
      "selector" = {
        "app" = "prometheus"
        "component" = "node-exporter"
        "release" = "prometheus"
      }
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "service_monitoring_prometheus_pushgateway" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "annotations" = {
        "prometheus.io/probe" = "pushgateway"
      }
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "pushgateway"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-pushgateway"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "http"
          "port" = 9091
          "protocol" = "TCP"
          "targetPort" = 9091
        },
      ]
      "selector" = {
        "app" = "prometheus"
        "component" = "pushgateway"
        "release" = "prometheus"
      }
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "service_monitoring_prometheus_server" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "server"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-server"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "http"
          "port" = 80
          "protocol" = "TCP"
          "targetPort" = 9090
        },
      ]
      "selector" = {
        "app" = "prometheus"
        "component" = "server"
        "release" = "prometheus"
      }
      "sessionAffinity" = "None"
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "daemonset_monitoring_prometheus_node_exporter" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "DaemonSet"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "node-exporter"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-node-exporter"
      "namespace" = "monitoring"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "prometheus"
          "component" = "node-exporter"
          "release" = "prometheus"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "prometheus"
            "chart" = "prometheus-14.6.0"
            "component" = "node-exporter"
            "heritage" = "Helm"
            "release" = "prometheus"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--path.procfs=/host/proc",
                "--path.sysfs=/host/sys",
                "--path.rootfs=/host/root",
                "--web.listen-address=:9100",
              ]
              "image" = "quay.io/prometheus/node-exporter:v1.1.2"
              "imagePullPolicy" = "IfNotPresent"
              "name" = "prometheus-node-exporter"
              "ports" = [
                {
                  "containerPort" = 9100
                  "hostPort" = 9100
                  "name" = "metrics"
                },
              ]
              "resources" = {}
              "volumeMounts" = [
                {
                  "mountPath" = "/host/proc"
                  "name" = "proc"
                  "readOnly" = true
                },
                {
                  "mountPath" = "/host/sys"
                  "name" = "sys"
                  "readOnly" = true
                },
                {
                  "mountPath" = "/host/root"
                  "mountPropagation" = "HostToContainer"
                  "name" = "root"
                  "readOnly" = true
                },
              ]
            },
          ]
          "hostNetwork" = true
          "hostPID" = true
          "securityContext" = {
            "fsGroup" = 65534
            "runAsGroup" = 65534
            "runAsNonRoot" = true
            "runAsUser" = 65534
          }
          "serviceAccountName" = "prometheus-node-exporter"
          "volumes" = [
            {
              "hostPath" = {
                "path" = "/proc"
              }
              "name" = "proc"
            },
            {
              "hostPath" = {
                "path" = "/sys"
              }
              "name" = "sys"
            },
            {
              "hostPath" = {
                "path" = "/"
              }
              "name" = "root"
            },
          ]
        }
      }
      "updateStrategy" = {
        "type" = "RollingUpdate"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_monitoring_prometheus_kube_state_metrics" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "prometheus"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "kube-state-metrics"
        "app.kubernetes.io/version" = "2.1.1"
        "helm.sh/chart" = "kube-state-metrics-3.4.2"
      }
      "name" = "prometheus-kube-state-metrics"
      "namespace" = "monitoring"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/name" = "kube-state-metrics"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app.kubernetes.io/instance" = "prometheus"
            "app.kubernetes.io/name" = "kube-state-metrics"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--port=8080",
                "--resources=certificatesigningrequests,configmaps,cronjobs,daemonsets,deployments,endpoints,horizontalpodautoscalers,ingresses,jobs,limitranges,mutatingwebhookconfigurations,namespaces,networkpolicies,nodes,persistentvolumeclaims,persistentvolumes,poddisruptionbudgets,pods,replicasets,replicationcontrollers,resourcequotas,secrets,services,statefulsets,storageclasses,validatingwebhookconfigurations,volumeattachments",
                "--telemetry-port=8081",
              ]
              "image" = "k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.1.1"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/healthz"
                  "port" = 8080
                }
                "initialDelaySeconds" = 5
                "timeoutSeconds" = 5
              }
              "name" = "kube-state-metrics"
              "ports" = [
                {
                  "containerPort" = 8080
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/"
                  "port" = 8080
                }
                "initialDelaySeconds" = 5
                "timeoutSeconds" = 5
              }
            },
          ]
          "hostNetwork" = false
          "securityContext" = {
            "fsGroup" = 65534
            "runAsGroup" = 65534
            "runAsUser" = 65534
          }
          "serviceAccountName" = "prometheus-kube-state-metrics"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_monitoring_prometheus_alertmanager" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "alertmanager"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-alertmanager"
      "namespace" = "monitoring"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "prometheus"
          "component" = "alertmanager"
          "release" = "prometheus"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "prometheus"
            "chart" = "prometheus-14.6.0"
            "component" = "alertmanager"
            "heritage" = "Helm"
            "release" = "prometheus"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--config.file=/etc/config/alertmanager.yml",
                "--storage.path=/data",
                "--cluster.advertise-address=[$(POD_IP)]:6783",
                "--web.external-url=http://localhost:9093",
              ]
              "env" = [
                {
                  "name" = "POD_IP"
                  "valueFrom" = {
                    "fieldRef" = {
                      "apiVersion" = "v1"
                      "fieldPath" = "status.podIP"
                    }
                  }
                },
              ]
              "image" = "quay.io/prometheus/alertmanager:v0.21.0"
              "imagePullPolicy" = "IfNotPresent"
              "name" = "prometheus-alertmanager"
              "ports" = [
                {
                  "containerPort" = 9093
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/-/ready"
                  "port" = 9093
                }
                "initialDelaySeconds" = 30
                "timeoutSeconds" = 30
              }
              "resources" = {}
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/config"
                  "name" = "config-volume"
                },
                {
                  "mountPath" = "/data"
                  "name" = "storage-volume"
                  "subPath" = ""
                },
              ]
            },
            {
              "args" = [
                "--volume-dir=/etc/config",
                "--webhook-url=http://127.0.0.1:9093/-/reload",
              ]
              "image" = "jimmidyson/configmap-reload:v0.5.0"
              "imagePullPolicy" = "IfNotPresent"
              "name" = "prometheus-alertmanager-configmap-reload"
              "resources" = {}
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/config"
                  "name" = "config-volume"
                  "readOnly" = true
                },
              ]
            },
          ]
          "securityContext" = {
            "fsGroup" = 65534
            "runAsGroup" = 65534
            "runAsNonRoot" = true
            "runAsUser" = 65534
          }
          "serviceAccountName" = "prometheus-alertmanager"
          "volumes" = [
            {
              "configMap" = {
                "name" = "prometheus-alertmanager"
              }
              "name" = "config-volume"
            },
            {
              "name" = "storage-volume"
              "persistentVolumeClaim" = {
                "claimName" = "prometheus-alertmanager"
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_monitoring_prometheus_pushgateway" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "pushgateway"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-pushgateway"
      "namespace" = "monitoring"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "prometheus"
          "component" = "pushgateway"
          "release" = "prometheus"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "prometheus"
            "chart" = "prometheus-14.6.0"
            "component" = "pushgateway"
            "heritage" = "Helm"
            "release" = "prometheus"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = null
              "image" = "prom/pushgateway:v1.3.1"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/-/healthy"
                  "port" = 9091
                }
                "initialDelaySeconds" = 10
                "timeoutSeconds" = 10
              }
              "name" = "prometheus-pushgateway"
              "ports" = [
                {
                  "containerPort" = 9091
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/-/ready"
                  "port" = 9091
                }
                "initialDelaySeconds" = 10
                "timeoutSeconds" = 10
              }
              "resources" = {}
            },
          ]
          "securityContext" = {
            "runAsNonRoot" = true
            "runAsUser" = 65534
          }
          "serviceAccountName" = "prometheus-pushgateway"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_monitoring_prometheus_server" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
        "chart" = "prometheus-14.6.0"
        "component" = "server"
        "heritage" = "Helm"
        "release" = "prometheus"
      }
      "name" = "prometheus-server"
      "namespace" = "monitoring"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "prometheus"
          "component" = "server"
          "release" = "prometheus"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "prometheus"
            "chart" = "prometheus-14.6.0"
            "component" = "server"
            "heritage" = "Helm"
            "release" = "prometheus"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--volume-dir=/etc/config",
                "--webhook-url=http://127.0.0.1:9090/-/reload",
              ]
              "image" = "jimmidyson/configmap-reload:v0.5.0"
              "imagePullPolicy" = "IfNotPresent"
              "name" = "prometheus-server-configmap-reload"
              "resources" = {}
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/config"
                  "name" = "config-volume"
                  "readOnly" = true
                },
              ]
            },
            {
              "args" = [
                "--storage.tsdb.retention.time=15d",
                "--config.file=/etc/config/prometheus.yml",
                "--storage.tsdb.path=/data",
                "--web.console.libraries=/etc/prometheus/console_libraries",
                "--web.console.templates=/etc/prometheus/consoles",
                "--web.enable-lifecycle",
              ]
              "image" = "quay.io/prometheus/prometheus:v2.26.0"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/-/healthy"
                  "port" = 9090
                }
                "initialDelaySeconds" = 30
                "periodSeconds" = 15
                "successThreshold" = 1
                "timeoutSeconds" = 10
              }
              "name" = "prometheus-server"
              "ports" = [
                {
                  "containerPort" = 9090
                },
              ]
              "readinessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/-/ready"
                  "port" = 9090
                }
                "initialDelaySeconds" = 30
                "periodSeconds" = 5
                "successThreshold" = 1
                "timeoutSeconds" = 4
              }
              "resources" = {}
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/config"
                  "name" = "config-volume"
                },
                {
                  "mountPath" = "/data"
                  "name" = "storage-volume"
                  "subPath" = ""
                },
              ]
            },
          ]
          "dnsPolicy" = "ClusterFirst"
          "enableServiceLinks" = true
          "hostNetwork" = false
          "securityContext" = {
            "fsGroup" = 65534
            "runAsGroup" = 65534
            "runAsNonRoot" = true
            "runAsUser" = 65534
          }
          "serviceAccountName" = "prometheus-server"
          "terminationGracePeriodSeconds" = 300
          "volumes" = [
            {
              "configMap" = {
                "name" = "prometheus-server"
              }
              "name" = "config-volume"
            },
            {
              "name" = "storage-volume"
              "persistentVolumeClaim" = {
                "claimName" = "prometheus-server"
              }
            },
          ]
        }
      }
    }
  }
}
