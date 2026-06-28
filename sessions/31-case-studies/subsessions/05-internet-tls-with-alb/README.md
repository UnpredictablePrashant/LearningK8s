# Case Study 05: Internet TLS With ALB

## Scenario

An application is ready for users and needs a real HTTPS endpoint. The team
needs to expose the app publicly through an AWS Application Load Balancer, use
an ACM certificate, redirect HTTP to HTTPS, and point DNS at the load balancer.

This is one of the most common EKS production paths because it connects
Kubernetes Ingress, AWS Load Balancer Controller, ACM, Route 53 or external DNS,
security groups, target health, and application readiness probes.

## Target Outcome

The app can:

- Run behind an internal `ClusterIP` Service.
- Be exposed through an internet-facing AWS ALB.
- Terminate TLS with an ACM certificate.
- Redirect HTTP port `80` to HTTPS port `443`.
- Respond successfully on the configured hostname.

The app should not:

- Use a `LoadBalancer` Service for every Deployment.
- Store TLS private keys in the app container.
- Expose Pods directly.
- Serve production HTTP without an HTTPS path.

## Important Concept

The Ingress is Kubernetes desired state. The AWS Load Balancer Controller turns
that desired state into AWS infrastructure.

```text
Kubernetes Ingress
  -> AWS Load Balancer Controller watches it
    -> controller creates or updates an AWS ALB
      -> ACM certificate is attached to the HTTPS listener
        -> ALB sends healthy traffic to Kubernetes Service targets
```

## Request Flow

```text
Browser requests https://app.example.com
  -> DNS resolves app.example.com to the ALB
    -> ALB terminates TLS with the ACM certificate
      -> ALB checks target health
        -> ALB forwards HTTP traffic to the Service target group
          -> Service sends traffic to ready Pods
```

## Objects Created

Kubernetes objects:

```text
Namespace: case-tls-ingress
Deployment: tls-demo
Service: tls-demo
Ingress: tls-demo
```

AWS objects created by the controller:

```text
Application Load Balancer
Listeners on 80 and 443
HTTPS listener with ACM certificate
Target group for the Kubernetes Service
Security group rules managed by the controller
```

## Prerequisites

You need:

- AWS Load Balancer Controller installed.
- An ACM certificate in the same AWS region as the ALB.
- A DNS name you control, such as `app.example.com`.
- Ability to create a DNS alias or CNAME to the ALB address.

Check the controller:

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl get ingressclass alb
```

If the controller is not installed, use the install flow from:

```text
sessions/08-ingress-edge-routing/subsessions/06-ingress/README.md
```

## Set Lab Variables

Run from this case study folder:

```bash
cd sessions/31-case-studies/subsessions/05-internet-tls-with-alb
```

Set the lab values:

```bash
export APP_HOSTNAME=app.example.com
export ACM_CERT_ARN=arn:aws:acm:us-east-2:111122223333:certificate/replace-me

export NAMESPACE=case-tls-ingress
```

## Step 1: Apply The App And TLS Ingress

Run:

```bash
bash scripts/01-apply-tls-ingress.sh
```

This script:

- Checks that the `alb` IngressClass exists.
- Applies the demo app Deployment and Service.
- Renders the hostname and ACM certificate ARN into the Ingress.
- Applies the Ingress.
- Prints the Ingress status.

## Step 2: Wait For The ALB Address

Watch the Ingress:

```bash
kubectl get ingress tls-demo -n case-tls-ingress -w
```

Wait until the `ADDRESS` column shows the ALB DNS name.

Describe the Ingress if it does not get an address:

```bash
kubectl describe ingress tls-demo -n case-tls-ingress
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

## Step 3: Point DNS To The ALB

Get the ALB DNS name:

```bash
export ALB_DNS_NAME="$(kubectl get ingress tls-demo -n case-tls-ingress \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

echo "$ALB_DNS_NAME"
```

Create one of these DNS records:

```text
Route 53 alias:
  app.example.com -> ALB DNS name

CNAME:
  app.example.com -> ALB DNS name
```

Use an alias record for a zone apex. Use a CNAME only for a subdomain.

## Step 4: Verify HTTPS And Redirect

After DNS resolves:

```bash
bash scripts/02-check-tls-ingress.sh
```

Expected behavior:

```text
http://app.example.com
  -> 301 or 302 redirect to https://app.example.com

https://app.example.com
  -> HTTP 200 from the demo app
```

You can also test directly:

```bash
curl -I "http://$APP_HOSTNAME"
curl -Ik "https://$APP_HOSTNAME"
```

## How The Pieces Work Together

The ACM certificate answers this AWS question:

```text
Which trusted certificate should the ALB present to browsers?
```

The Ingress annotations answer this controller question:

```text
Should the ALB be public or internal, which listeners should exist, and which
certificate should be attached?
```

The Service answers this Kubernetes question:

```text
Which ready Pods should receive traffic?
```

The readiness probe answers this traffic-safety question:

```text
Should this Pod be included in ALB target health and Service endpoints yet?
```

The DNS record answers this user-facing question:

```text
How do users find the ALB through the application hostname?
```

## Production Guidance

- Keep Services internal by default; expose through Ingress or Gateway only when
  needed.
- Use ACM for public TLS certificates instead of storing private keys in app
  containers.
- Match the ACM certificate SAN with the exact hostname.
- Use HTTP-to-HTTPS redirect.
- Use readiness probes that represent real app readiness.
- Review ALB health checks, target group health, and security groups when
  traffic fails.
- Use ExternalDNS only after the manual DNS path is understood.
- Consider AWS WAF, access logs, and deletion protection for production ALBs.

## Common Mistakes

- ACM certificate is in a different region from the ALB.
- DNS points to the wrong ALB.
- Ingress has no `alb` IngressClass.
- Service target port does not match the Pod container port.
- Readiness probe fails, so the ALB target group has no healthy targets.
- Certificate does not include the requested hostname.
- Security groups or network policy block the health check path.

## Cleanup

Run:

```bash
bash scripts/03-cleanup-tls-ingress.sh
```

Also remove the DNS record after the Ingress is deleted. The script does not
delete ACM certificates or DNS records.

## References

- AWS Load Balancer Controller: `https://kubernetes-sigs.github.io/aws-load-balancer-controller/`
- AWS Load Balancer Controller Ingress annotations: `https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/`
- AWS Load Balancer Controller Ingress guide: `https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/ingress_class/`
- AWS Certificate Manager: `https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html`
- Kubernetes Ingress: `https://kubernetes.io/docs/concepts/services-networking/ingress/`
