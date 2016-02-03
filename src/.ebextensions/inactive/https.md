# Using the HTTPS Configuration Files
There are several ways to configure your project to use HTTPS. The simplest way is to configure the environment's load balancer to terminate HTTPS connections and use HTTP to communicate with instances on the backend. Start with this method to confirm that your certificate works.

If [AWS Certificate Manager (ACM)](https://console.aws.amazon.com/acm) is available in your region, you can use it to create a managed certificate for any domain that you own for free. If you have purchased a certificate or have a self-signed certificate, you can [upload it to IAM with the AWS CLI](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/configuring-https-ssl-upload.html).

Other methods involve terminating HTTPS at the instance and require your instances to have the public certificate and private key. Store the private key in a secure Amazon S3 bucket and ensure that your instance has permission to read to the bucket and object in its [instance profile](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts-roles.html). The easiest way to do this is to put the key in your Elastic Beanstalk storage bucket and use the sample instance profile in the [Developer Guide](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts-roles.html#concepts-roles-instance).

Six configuration files are provided for use in different combinations to enable each method: 

- `https-instance.config`
- `https-instance-single.config`
- `https-lbpassthrough.config`
- `https-lbreencrypt.config`
- `https-lbterminate.config`
- `https-lbterminate-listener.config`


## Terminate HTTPS at the load balancer with HTTP on the backend (client-to-AWS encryption)
The method requires a managed certificate created with [AWS Certificate Manager (ACM)](https://console.aws.amazon.com/acm) or uploaded to IAM. 

### To enable client-to-AWS HTTPS
1. Modify `https-lbterminate.config` with the ARN of your certificate:
	
	   - namespace:  aws:elb:loadbalancer
	     option_name:  SSLCertificateId
	     value:  arn:aws:acm:us-east-1:#############:certificate/############
2. Modify `https-lbterminate.config` with the ID of your VPC (default or custom):

	   loadbalancersg:
	     Type: AWS::EC2::SecurityGroup
	     Properties:
	       GroupDescription: load balancer security group
	       VpcId: vpc-########
		
3. Move `https-lbterminate.config` and `https-lbterminate-listener.config` into `src/.ebextensions` and move `http-healthcheckurl.config` into `src/.ebextensions/inactive`.
4. Build and deploy.

## Terminate HTTPS at the load balancer with HTTPS on the backend (end-to-end encryption)
The method requires a managed certificate (for the load balancer), as well as a signed public certificate and the private key used to sign the certificate for the instances on the backend. This method is more secure but requires additional configuration. You can use a managed certificate for the front end, and a self signed certificate for the backend.

### To enable end-to-end HTTPS
1. Modify `https-lbterminate.config` with the ARN of your certificate:
	
	   - namespace:  aws:elb:loadbalancer
	     option_name:  SSLCertificateId
	     value:  arn:aws:acm:us-east-1:#############:certificate/############
2. Modify `https-lbterminate.config` with the ID of your VPC (default or custom):

	   loadbalancersg:
	     Type: AWS::EC2::SecurityGroup
	     Properties:
	       GroupDescription: load balancer security group
	       VpcId: vpc-########
3. Modify `https-lbreencrypt.config` with the contents of your public certificate:

       Attributes : 
         - Name : PublicKey
           Value : |
             ################################################################
             ################################################################

4. Modify `https-instance.config` with your bucket name:

       AWS::CloudFormation::Authentication:
         S3Auth:
           type: "s3"
           buckets: ["elasticbeanstalk-#########-#############"]
5. Modify `https-instance.config` with the URL of the private key:

       /etc/pki/tls/certs/server.key:
         mode: "000400"
         owner: root
         group: root
         authentication: "S3Auth"
         source: https://s3-#########.amazonaws.com/elasticbeanstalk-#########-#############/server.key
6. Modify `https-instance.config` with the contents of your public certificate:

       /etc/pki/tls/certs/server.crt:
         mode: "000400"
         owner: root
         group: root
         content: |
           -----BEGIN CERTIFICATE-----
           ################################################################
           ################################################################
7. Move `https-lbterminate.config`, `https-lbreencrypt.config` and `https-instance.config` into `src/.ebextensions` and move `http-healthcheckurl.config` into `src/.ebextensions/inactive`.
8. Build and deploy.

## Terminate at the instance (single instance environments)
In a single instance environment, you need a public certificate and private key for your instance. The downside to this method is that your instance is directly exposed to the Internet, you cannot use a free certificate from ACM, and your environment cannot scale or use rolling updates. Use this method for testing and development.

### To enable single instance HTTPS
1. Modify `https-instance.config` with your bucket name:

       AWS::CloudFormation::Authentication:
         S3Auth:
           type: "s3"
           buckets: ["elasticbeanstalk-#########-#############"]
2. Modify `https-instance.config` with the URL of the private key:

       /etc/pki/tls/certs/server.key:
         mode: "000400"
         owner: root
         group: root
         authentication: "S3Auth"
         source: https://s3-#########.amazonaws.com/elasticbeanstalk-#########-#############/server.key
3. Modify `https-instance.config` with the contents of your public certificate:

       /etc/pki/tls/certs/server.crt:
         mode: "000400"
         owner: root
         group: root
         content: |
           -----BEGIN CERTIFICATE-----
           ################################################################
           ################################################################

4. Move `https-instance.config` and `https-instance-single.config` into `src/.ebextensions` and move `http-healthcheckurl.config` into `src/.ebextensions/inactive`.
5. Build and deploy.

## Terminate at the instance (load balancer passthrough)
This method also terminates at the instance, but in a load balanced environment where the load balancer is not configured to terminate HTTPS, but rather passes through encrypted TCP packets as-is. The down side to this method is that the load balancer cannot see the requests and thus cannot optimize routing or report response metrics.

### To enable load balancer passthrough HTTPS
1. Modify `https-instance.config` with your bucket name:

       AWS::CloudFormation::Authentication:
         S3Auth:
           type: "s3"
           buckets: ["elasticbeanstalk-#########-#############"]
2. Modify `https-instance.config` with the URL of the private key:

       /etc/pki/tls/certs/server.key:
         mode: "000400"
         owner: root
         group: root
         authentication: "S3Auth"
         source: https://s3-#########.amazonaws.com/elasticbeanstalk-#########-#############/server.key
3. Modify `https-instance.config` with the contents of your public certificate:

       /etc/pki/tls/certs/server.crt:
         mode: "000400"
         owner: root
         group: root
         content: |
           -----BEGIN CERTIFICATE-----
           ################################################################
           ################################################################

4. Modify `https-lbpassthrough.config` with the ID of your VPC:

       loadbalancersg:
         Type: AWS::EC2::SecurityGroup
         Properties:
           GroupDescription: load balancer security group
           VpcId: vpc-########
5. Move `https-instance.config` and `https-lbpassthrough.config` into `src/.ebextensions` and move `http-healthcheckurl.config` into `src/.ebextensions/inactive`.
6. Build and deploy.