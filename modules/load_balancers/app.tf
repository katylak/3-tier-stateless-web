/**
#################################################################################################################
*
*                               Load Balancer Section for the App LB
*                                 Start Here of the App LB Section 
*
#################################################################################################################
*/

/**
* Load Balancer For App
**/
resource "ibm_is_lb" "app_lb" {
  name           = "${var.prefix}app-lb"
  resource_group = var.resource_group
  type           = "private"
  subnets        = var.app_subnet
}

/**
* Output Variable
* Element : Load Balancer
* LB ID For App
* This variable will expose the LB ID for App
**/
output "app_lb_id" {
  value       = ibm_is_lb.app_lb.id
  description = "App load balancer ID"
}

/**
* Output Variable
* Element : Load Balancer IP
* LB IP For App
* This variable will expose the LB IP for App
**/
output "app_lb_ip" {
  value       = ibm_is_lb.db_lb.private_ips
  description = "App load balancer IP"
}

/**
* Output Variable
* Element : Load Balancer Hostname
* LB Hostname For App
* This variable output the Load Balancer's Hostname for App
**/
output "app_lb_hostname" {
  value       = ibm_is_lb.db_lb.hostname
  description = "App load balancer Hostname"
}


/**
* Load Balancer Listener For App
**/
resource "ibm_is_lb_listener" "app_listener" {
  lb           = ibm_is_lb.app_lb.id
  protocol     = var.lb_protocol["80"]
  port         = "80"
  default_pool = ibm_is_lb_pool.app_pool.id
  depends_on   = [ibm_is_lb_pool.app_pool]
}

/**
* Load Balancer Pool For App
**/
resource "ibm_is_lb_pool" "app_pool" {
  lb                 = ibm_is_lb.app_lb.id
  name               = "${var.prefix}app-pool"
  protocol           = var.lb_protocol["80"]
  algorithm          = var.lb_algo["rr"]
  health_delay       = "5"
  health_retries     = "2"
  health_timeout     = "2"
  health_type        = var.lb_protocol["80"]
  health_monitor_url = "/"
  depends_on         = [ibm_is_lb.app_lb]
}

/**
* Output Variable
* Element : LB Pool
* Pool ID For App
* This variable will expose the Pool Id
**/
output "app_lb_pool_id" {
  value       = ibm_is_lb_pool.app_pool.id
  description = "App load balancer pool ID"
}

/**
* Load Balancer Pool Member For App
**/
resource "ibm_is_lb_pool_member" "app_lb_member" {
  count          = length(var.total_instance) * length(var.zones)
  lb             = ibm_is_lb.app_lb.id
  pool           = ibm_is_lb_pool.app_pool.id
  port           = var.lb_port_number["http"]
  target_address = element(var.app_target, count.index)
  depends_on     = [ibm_is_lb_listener.app_listener, var.app_vsi]
}

/**               
#################################################################################################################
*                              End of the App Load Balancer Section 
#################################################################################################################
**/
