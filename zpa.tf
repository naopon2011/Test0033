provider "zpa" {
  zpa_client_id         =  var.zpa_client_id
  zpa_client_secret     =  var.zpa_client_secret
  zpa_customer_id       =  var.zpa_customer_id 
}

# AWS上のWindowsサーバ向けアプリケーションセグメントの作成
# Create Application Segment for Windows Server which is created on AWS
resource "zpa_application_segment" "windows" {
  name             = "windows_on_aws_created_by_terraform"
  description      = "windows_on_aws_created_by_terraform"
  enabled          = true
  health_reporting = "ON_ACCESS"
  bypass_type      = "NEVER"
  is_cname_enabled = true
  tcp_port_ranges   = ["3389", "3389"]
  udp_port_ranges   = ["3389", "3389"]
  domain_names     = ["${aws_instance.windows.private_dns}"]
  segment_group_id = zpa_segment_group.win_app_group.id
  server_groups {
    id = [zpa_server_group.win_servers.id]
  }
}

# AWS上のWindowsサーバ向けサーバグループの作成
# Create Server Group for Windows Server which is created on AWS
resource "zpa_server_group" "win_servers" {
  name              = "Win Servers Group created by terraform"
  description       = "Win Servers Group created by terraform"
  enabled           = true
  dynamic_discovery = true
  app_connector_groups {
    id = [data.zpa_app_connector_group.aws_connector_group.id]
  }
}

# AWS上のWindowsサーバ向けセグメントグループの作成
# Create Segment Group
resource "zpa_segment_group" "win_app_group" {
  name            = "Win App group created by terraform"
  description     = "Win App group created by terraform"
  enabled         = true
}

# AWS上のWindowsサーバ向けのアクセスポリシーの作成
# Create Access Policy for Windows Server which is created on AWS
resource "zpa_policy_access_rule" "windows_access_policy" {
  name                          = "Access policy created by terraform"
  description                   = "Access policy created by terraform"
  action                        = "ALLOW"
  operator = "AND"
  policy_set_id = data.zpa_policy_type.access_policy.id

  conditions {
    negated = false
    operator = "OR"
    operands {
      name =  "Example"
      object_type = "APP_GROUP"
      lhs = "id"
      rhs = zpa_segment_group.win_app_group.id
    }
  }
}

# Azure上のWindows10向けアプリケーションセグメントの作成
# Create Application Segment for target application(Windows 10) which is created on Azure
resource "zpa_application_segment" "target" {
  name             = "target application created by terraform"
  description      = "target application created by terraform"
  enabled          = true
  health_reporting = "ON_ACCESS"
  bypass_type      = "NEVER"
  is_cname_enabled = true
  tcp_port_ranges   = ["3389", "3389"]
  udp_port_ranges   = ["3389", "3389"]
  domain_names     = ["target.internal.cloudapp.net"]
  segment_group_id = zpa_segment_group.test_client_app_group.id
  server_groups {
    id = [zpa_server_group.azure.id]
  }
}

# Azure上のWindows10向けサーバグループの作成
# Create Server Group for target application(Windows 10) which is created on Azure
resource "zpa_server_group" "azure" {
  name              = "Servers Group for Azure created by terraform"
  description       = "Servers Group for Azure created by terraform"
  enabled           = true
  dynamic_discovery = true
  app_connector_groups {
    id = [data.zpa_app_connector_group.azure_connector_group.id]
  }
}

# Azure上のWindows10向けセグメントグループの作成
# Create Segment Group for target application(Windows 10) which is created on Azure
resource "zpa_segment_group" "test_client_app_group" {
  name            = "Target App group created by terraform"
  description     = "Target App group created by terraform"
  enabled         = true
}

# Azure上のWindows10向けアクセスポリシーの作成
# Create Access Policy for target application(Windows 10) which is created on Azure
resource "zpa_policy_access_rule" "access_policy_for_test_client" {
  name                          = "Target App Access policy created by terraform"
  description                   = "Target App Access policy created by terraform"
  action                        = "ALLOW"
  operator = "AND"
  policy_set_id = data.zpa_policy_type.access_policy.id

  conditions {
    negated = false
    operator = "OR"
    operands {
      name =  "Example"
      object_type = "APP_GROUP"
      lhs = "id"
      rhs = zpa_segment_group.test_client_app_group.id
    }
  }
}

# Azure用App Connectorグループの検索
# Retrieve Azure App Connector Group
data "zpa_app_connector_group" "azure_connector_group" {
  name = var.azure_ac_group
}

# AWS用App Connectorグループの検索
# Retrieve AWS App Connector Group
data "zpa_app_connector_group" "aws_connector_group" {
  name = var.aws_ac_group
}

data "zpa_policy_type" "access_policy" {
    policy_type = "ACCESS_POLICY"
}
