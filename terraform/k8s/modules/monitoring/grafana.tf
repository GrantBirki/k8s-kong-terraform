resource "kubernetes_manifest" "podsecuritypolicy_grafana" {
  manifest = {
    "apiVersion" = "policy/v1beta1"
    "kind" = "PodSecurityPolicy"
    "metadata" = {
      "annotations" = {
        "apparmor.security.beta.kubernetes.io/allowedProfileNames" = "runtime/default"
        "apparmor.security.beta.kubernetes.io/defaultProfileName" = "runtime/default"
        "seccomp.security.alpha.kubernetes.io/allowedProfileNames" = "docker/default,runtime/default"
        "seccomp.security.alpha.kubernetes.io/defaultProfileName" = "docker/default"
      }
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana"
    }
    "spec" = {
      "allowPrivilegeEscalation" = false
      "fsGroup" = {
        "ranges" = [
          {
            "max" = 65535
            "min" = 1
          },
        ]
        "rule" = "MustRunAs"
      }
      "hostIPC" = false
      "hostNetwork" = false
      "hostPID" = false
      "privileged" = false
      "readOnlyRootFilesystem" = false
      "requiredDropCapabilities" = [
        "ALL",
      ]
      "runAsUser" = {
        "rule" = "MustRunAsNonRoot"
      }
      "seLinux" = {
        "rule" = "RunAsAny"
      }
      "supplementalGroups" = {
        "ranges" = [
          {
            "max" = 65535
            "min" = 1
          },
        ]
        "rule" = "MustRunAs"
      }
      "volumes" = [
        "configMap",
        "emptyDir",
        "projected",
        "csi",
        "secret",
        "downwardAPI",
        "persistentVolumeClaim",
      ]
    }
  }
}

resource "kubernetes_manifest" "podsecuritypolicy_grafana_test" {
  manifest = {
    "apiVersion" = "policy/v1beta1"
    "kind" = "PodSecurityPolicy"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana-test"
    }
    "spec" = {
      "allowPrivilegeEscalation" = true
      "fsGroup" = {
        "rule" = "RunAsAny"
      }
      "hostIPC" = false
      "hostNetwork" = false
      "hostPID" = false
      "privileged" = false
      "runAsUser" = {
        "rule" = "RunAsAny"
      }
      "seLinux" = {
        "rule" = "RunAsAny"
      }
      "supplementalGroups" = {
        "rule" = "RunAsAny"
      }
      "volumes" = [
        "configMap",
        "downwardAPI",
        "emptyDir",
        "projected",
        "csi",
        "secret",
      ]
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_monitoring_grafana" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_monitoring_grafana_test" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana-test"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "secret_monitoring_grafana" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "admin-password" = "NFl3TndhR3RpTE5QMG1VNFpETGtvdHFnelBsRU1VdW9RTlg5REMyaQ=="
      "admin-user" = "YWRtaW4="
      "ldap-toml" = ""
    }
    "kind" = "Secret"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
    "type" = "Opaque"
  }
}

resource "kubernetes_manifest" "configmap_monitoring_grafana" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "dashboardproviders.yaml" = <<-EOT
      apiVersion: 1
      providers:
      - disableDeletion: false
        editable: true
        folder: ""
        name: default
        options:
          path: /var/lib/grafana/dashboards/default
        orgId: 1
        type: file
      
      EOT
      "datasources.yaml" = <<-EOT
      apiVersion: 1
      datasources:
      - access: proxy
        isDefault: true
        name: Prometheus
        type: prometheus
        url: http://prometheus-server
      
      EOT
      "download_dashboards.sh" = <<-EOT
      #!/usr/bin/env sh
      set -euf
      mkdir -p /var/lib/grafana/dashboards/default
      curl -skf \
      --connect-timeout 60 \
      --max-time 60 \
      -H "Accept: application/json" \
      -H "Content-Type: application/json;charset=UTF-8" \
        "https://grafana.com/api/dashboards/7424/revisions/5/download" | sed '/-- .* --/! s/"datasource":.*,/"datasource": "Prometheus",/g'\
      > "/var/lib/grafana/dashboards/default/kong-dash.json"
      EOT
      "grafana.ini" = <<-EOT
      [analytics]
      check_for_updates = true
      [grafana_net]
      url = https://grafana.net
      [log]
      mode = console
      [paths]
      data = /var/lib/grafana/
      logs = /var/log/grafana
      plugins = /var/lib/grafana/plugins
      provisioning = /etc/grafana/provisioning
      
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "configmap_monitoring_grafana_dashboards_default" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {}
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "dashboard-provider" = "default"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana-dashboards-default"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "configmap_monitoring_grafana_test" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "run.sh" = <<-EOT
      @test "Test Health" {
        url="http://grafana/api/health"
      
        code=$(wget --server-response --spider --timeout 10 --tries 1 $${url} 2>&1 | awk '/^  HTTP/{print $2}')
        [ "$code" == "200" ]
      }
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana-test"
      "namespace" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "persistentvolumeclaim_monitoring_grafana" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolumeClaim"
    "metadata" = {
      "finalizers" = [
        "kubernetes.io/pvc-protection",
      ]
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "resources" = {
        "requests" = {
          "storage" = "10Gi"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "clusterrole_grafana_clusterrole" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana-clusterrole"
    }
    "rules" = []
  }
}

resource "kubernetes_manifest" "clusterrolebinding_grafana_clusterrolebinding" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana-clusterrolebinding"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "grafana-clusterrole"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "grafana"
        "namespace" = "monitoring"
      },
    ]
  }
}

resource "kubernetes_manifest" "role_monitoring_grafana" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
    "rules" = [
      {
        "apiGroups" = [
          "extensions",
        ]
        "resourceNames" = [
          "grafana",
        ]
        "resources" = [
          "podsecuritypolicies",
        ]
        "verbs" = [
          "use",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_monitoring_grafana_test" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana-test"
      "namespace" = "monitoring"
    }
    "rules" = [
      {
        "apiGroups" = [
          "policy",
        ]
        "resourceNames" = [
          "grafana-test",
        ]
        "resources" = [
          "podsecuritypolicies",
        ]
        "verbs" = [
          "use",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_monitoring_grafana" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "grafana"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "grafana"
        "namespace" = "monitoring"
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_monitoring_grafana_test" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana-test"
      "namespace" = "monitoring"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "grafana-test"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "grafana-test"
        "namespace" = "monitoring"
      },
    ]
  }
}

resource "kubernetes_manifest" "service_monitoring_grafana" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ports" = [
        {
          "name" = "service"
          "port" = 80
          "protocol" = "TCP"
          "targetPort" = 3000
        },
      ]
      "selector" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/name" = "grafana"
      }
      "type" = "ClusterIP"
    }
  }
}

resource "kubernetes_manifest" "deployment_monitoring_grafana" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana"
      "namespace" = "monitoring"
    }
    "spec" = {
      "replicas" = 1
      "revisionHistoryLimit" = 10
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/instance" = "grafana"
          "app.kubernetes.io/name" = "grafana"
        }
      }
      "strategy" = {
        "type" = "RollingUpdate"
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "checksum/config" = "b83e6f65edec2dc4037f60271b25d2547ae40d01c33fb75e00e448dfb6fe4a6b"
            "checksum/dashboards-json-config" = "e7de8eaaa1dff4c1e46ca799264788cb3131c62d4e0d82dd63e902ad7716f69f"
            "checksum/sc-dashboard-provider-config" = "01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b"
            "checksum/secret" = "7efb850520c8ba63572efbc951d4b81745f6f58a2c0a00e8ce53ffa06c951c25"
          }
          "labels" = {
            "app.kubernetes.io/instance" = "grafana"
            "app.kubernetes.io/name" = "grafana"
          }
        }
        "spec" = {
          "automountServiceAccountToken" = true
          "containers" = [
            {
              "env" = [
                {
                  "name" = "GF_SECURITY_ADMIN_USER"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "admin-user"
                      "name" = "grafana"
                    }
                  }
                },
                {
                  "name" = "GF_SECURITY_ADMIN_PASSWORD"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "admin-password"
                      "name" = "grafana"
                    }
                  }
                },
                {
                  "name" = "GF_PATHS_DATA"
                  "value" = "/var/lib/grafana/"
                },
                {
                  "name" = "GF_PATHS_LOGS"
                  "value" = "/var/log/grafana"
                },
                {
                  "name" = "GF_PATHS_PLUGINS"
                  "value" = "/var/lib/grafana/plugins"
                },
                {
                  "name" = "GF_PATHS_PROVISIONING"
                  "value" = "/etc/grafana/provisioning"
                },
              ]
              "image" = "grafana/grafana:8.1.2"
              "imagePullPolicy" = "IfNotPresent"
              "livenessProbe" = {
                "failureThreshold" = 10
                "httpGet" = {
                  "path" = "/api/health"
                  "port" = 3000
                }
                "initialDelaySeconds" = 60
                "timeoutSeconds" = 30
              }
              "name" = "grafana"
              "ports" = [
                {
                  "containerPort" = 80
                  "name" = "service"
                  "protocol" = "TCP"
                },
                {
                  "containerPort" = 3000
                  "name" = "grafana"
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/api/health"
                  "port" = 3000
                }
              }
              "resources" = {}
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/grafana/grafana.ini"
                  "name" = "config"
                  "subPath" = "grafana.ini"
                },
                {
                  "mountPath" = "/var/lib/grafana"
                  "name" = "storage"
                },
                {
                  "mountPath" = "/etc/grafana/provisioning/datasources/datasources.yaml"
                  "name" = "config"
                  "subPath" = "datasources.yaml"
                },
                {
                  "mountPath" = "/etc/grafana/provisioning/dashboards/dashboardproviders.yaml"
                  "name" = "config"
                  "subPath" = "dashboardproviders.yaml"
                },
              ]
            },
          ]
          "enableServiceLinks" = true
          "initContainers" = [
            {
              "command" = [
                "chown",
                "-R",
                "472:472",
                "/var/lib/grafana",
              ]
              "image" = "busybox:1.31.1"
              "imagePullPolicy" = "IfNotPresent"
              "name" = "init-chown-data"
              "resources" = {}
              "securityContext" = {
                "runAsNonRoot" = false
                "runAsUser" = 0
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/var/lib/grafana"
                  "name" = "storage"
                },
              ]
            },
            {
              "args" = [
                "-c",
                "mkdir -p /var/lib/grafana/dashboards/default && /bin/sh -x /etc/grafana/download_dashboards.sh",
              ]
              "command" = [
                "/bin/sh",
              ]
              "env" = null
              "image" = "curlimages/curl:7.73.0"
              "imagePullPolicy" = "IfNotPresent"
              "name" = "download-dashboards"
              "resources" = {}
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/grafana/download_dashboards.sh"
                  "name" = "config"
                  "subPath" = "download_dashboards.sh"
                },
                {
                  "mountPath" = "/var/lib/grafana"
                  "name" = "storage"
                },
              ]
            },
          ]
          "securityContext" = {
            "fsGroup" = 472
            "runAsGroup" = 472
            "runAsUser" = 472
          }
          "serviceAccountName" = "grafana"
          "volumes" = [
            {
              "configMap" = {
                "name" = "grafana"
              }
              "name" = "config"
            },
            {
              "configMap" = {
                "name" = "grafana-dashboards-default"
              }
              "name" = "dashboards-default"
            },
            {
              "name" = "storage"
              "persistentVolumeClaim" = {
                "claimName" = "grafana"
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "pod_monitoring_grafana_test" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Pod"
    "metadata" = {
      "annotations" = {
        "helm.sh/hook" = "test-success"
      }
      "labels" = {
        "app.kubernetes.io/instance" = "grafana"
        "app.kubernetes.io/managed-by" = "Helm"
        "app.kubernetes.io/name" = "grafana"
        "app.kubernetes.io/version" = "8.1.2"
        "helm.sh/chart" = "grafana-6.16.4"
      }
      "name" = "grafana-test"
      "namespace" = "monitoring"
    }
    "spec" = {
      "containers" = [
        {
          "command" = [
            "/opt/bats/bin/bats",
            "-t",
            "/tests/run.sh",
          ]
          "image" = "bats/bats:v1.1.0"
          "imagePullPolicy" = "IfNotPresent"
          "name" = "grafana-test"
          "volumeMounts" = [
            {
              "mountPath" = "/tests"
              "name" = "tests"
              "readOnly" = true
            },
          ]
        },
      ]
      "restartPolicy" = "Never"
      "serviceAccountName" = "grafana-test"
      "volumes" = [
        {
          "configMap" = {
            "name" = "grafana-test"
          }
          "name" = "tests"
        },
      ]
    }
  }
}
