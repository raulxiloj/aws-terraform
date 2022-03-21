# aws-terraform

<p>
<img src="https://user-images.githubusercontent.com/30850990/158814909-6250ddb4-ccc6-426d-8006-6eaaf47c2880.png" width="400" >
</p>


Terraform es una herramienta open-source del tipo IAC (infrastructure as code) que provee una CLI por la cual se ejecutan los comandos necesarios para manejar la infraestructura en diferentes proveedores de la nube. 

Terraform cuenta con mas de 1000 proveedores, un `proveedor` no es mas que una abstraccion logica que hace referencia a una API dependiendo del proveedor a utilizar, por medio de este interactuamos y creamos recursos. Entre los mas populares se encuentran:
- aws
- azure
- gcp
- k8s

Para poder conectarnos hacia un proveedor es por medio un `Access Key` o algun `Token` (dependera del proveedor). Pero no es recomendable ya que como en este caso se estara subiendo a algun repositorio publico y estas llaves se podran ver. Por lo cual se recomienda solo especificar el proveedor y configurar las llaves en la consola.

El ejemplo a continuacion consiste en crear un proyecto basado utilizando modulos, variables y otras configuraciones. 
- Se debe de crear una vpc (3 subnets privadas, 3 subnets publicas, 1 internet gateway, 1 nat gateway, 2 Route tables [1 publica y 1 privada])
- Se debe de crear un modulo EC2 
- Se debe de configurar un S3 Backend
- Se deben de utilizar variables (`.tfvars`) para parametrizar el proyecto
- El proveedor a utilizar es AWS. 

## Ejecucion
Para poder probar el proyecto se tienen que ejecutar los siguientes comandos, esto se tiene que hacer posteriormente de haber configurado las credenciales de aws en su consola.

Si se desea trabajar en equipo un proyecto de terraform, es recomendable crear un `backend` en el cual se estara guardando el estado y que todos puedan acceder al mismo estado y no existan inconsistencias, de igual manera poder bloquear el estado cuando alguien esta aplicando cambios. Para esto es el archivo `state.tf` en el cual creamos los recursos para guardar el estado en un bucket de `s3` y bloquearlo utilizando una tabla en `dynamodb`.

Al inicio en el archivo `provider.tf` que es el archivo principal se tiene comentado la parte de los modulos con el fin de primero configurar el `backend`.

```
# module "vpc" {
#     source = "./modules/vpc"
#     vpc_cidr = "10.0.0.0/24"
# }

# module "sg" {
#     source = "./modules/sg"
#     vpc_id = module.vpc.vpc_id
# }

# data "aws_ami" "ubuntu" {
#     most_recent = true

#     filter {
#         name = "name"
#         values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#     }

#     filter {
#         name = "virtualization-type"
#         values = ["hvm"]
#     }

#     filter {
#         name = "architecture"
#         values = ["x86_64"]
#     }

#     owners = ["099720109477"]
# }

# module "ec2" {
#     source = "./modules/ec2"
#     instance_ami = data.aws_ami.ubuntu.id
#     subnet_id = module.vpc.public_subnets[0].id
#     sg_ec2 = [module.sg.sg_server]
# }
```
- *Posteriormente lo descomentaremos.*

1. Para iniciar el proyecto utilizamos el siguiente comando
    ```
    terraform init
    ```
<p align="center">
    <img src="https://user-images.githubusercontent.com/30850990/159146669-d5c15746-d131-466c-9232-c0b5f62ee750.png"/>
</p>

### Configuracion del backend

*Nota: La configuracion del backend se podria hacer de manera manual utilizando la interfaz de aws y crear el bucket, la tabla  y por ultimo solo correr el paso 3, pero para automatizarlo un poco mas crearemos los archivos desde terraform :)*

2. Para crear los recursos ejecutamos el siguiente comando, el cual ejecutara los archivos con extension `.tf` (en este caso solo ejecutara el `provider.tf`y el `state.tf` debido a que los modulos aun no se estan llamando)
    ```
    terraform apply
    ```

<p align="center">
    <img src="https://user-images.githubusercontent.com/30850990/159147293-8d6b6386-0ab8-40d3-a0e2-654803111555.png"/>
</p>

<p align="center">
    <img src="https://user-images.githubusercontent.com/30850990/159147311-695ab95c-bc75-4d6b-98e1-86b119d687ab.png"/>
</p>

3. Por ultimo se tiene que asociar la tabla y el bucket creado como `backend` para que el estado se guarde ahi, esto no se podia hacer antes debido a que se necesita que los recursos existieran. En el archivo `state.tf` agregar los siguientes cambios al inicio del archivo:
    ```
    terraform {
        backend "s3" {
            bucket         = "trambo-tf-rx"
            key            = "state/terraform.tfstate"
            region         = "us-east-1"
            dynamodb_table = "terraform-state"
        }
    }
    ```
    - Basicamente indicamos que queremos utilizar S3 como nuestro backend en vez de nuestra computadora. 
 
4. Se debe de volver a ejecutar el comando `terraform init` debido a que estamos cambiando el manejo del estado (`backend`):
    ```
    terraform init
    ```
<p align="center">
    <img src="https://user-images.githubusercontent.com/30850990/159147582-d06aadf3-5dcf-4e97-858b-2b45dd084765.png"/>
</p>

Si verificamos nuestro bucket:
<p align="center">
    <img src="https://user-images.githubusercontent.com/30850990/159147586-4946141e-d0d5-4d67-85d3-bb81b3cc9a30.png"/>
</p>

- Ahora todos los cambios se estaran guardando en s3.

### Creacion de la infraestructura
5. Descomentamos la llamada de los modulos en el archivo `provider.tf`.
    ```
    module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = "10.0.0.0/24"
    }

    module "sg" {
        source = "./modules/sg"
        vpc_id = module.vpc.vpc_id
    }

    data "aws_ami" "ubuntu" {
        most_recent = true

        filter {
            name = "name"
            values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
        }

        filter {
            name = "virtualization-type"
            values = ["hvm"]
        }

        filter {
            name = "architecture"
            values = ["x86_64"]
        }

        owners = ["099720109477"]
    }

    module "ec2" {
        source = "./modules/ec2"
        instance_ami = data.aws_ami.ubuntu.id
        subnet_id = module.vpc.public_subnets[0].id
        sg_ec2 = [module.sg.sg_server]
    }
    ```
    Debido a que utilizamos modulos, se tiene que volver a ejecutar el comando `init` para que se installen los requerimientos del mismo. Posteriormente ejecutamos el comando `apply`.
    ```
    terraform init
    ```

    <p align="center">
        <img src="https://user-images.githubusercontent.com/30850990/159147817-057b5384-b69a-49ac-8bac-17816be6fb51.png"/>
    </p>

    ```
    terraform apply
    ```
    <p align="center">
        <img src="https://user-images.githubusercontent.com/30850990/159194198-2f68ad7a-31f5-4694-a154-ddb0092b120e.png"/>
    </p>
    
    Terraform crea los recursos segun los vaya necesitando. En este caso primero la vpc, luego las subnets, ig, etc.
    <p align="center">
        <img src="https://user-images.githubusercontent.com/30850990/159194333-7980713e-706b-4355-a430-3d7d49cd2b48.png"/>
    </p>
    
    Verificamos en la interfaz de amazon y se pueden observar la vpc, subnets, internet gateway, NAT, sg, EC2, entre otros que fueron creadas con exito.
    <p align="center">
        <img src="https://user-images.githubusercontent.com/30850990/159189069-66e598bf-8e1e-43e0-9096-6b8e79c6d5d3.png"/>
    </p>

    Nuestra EC2 fue creada con exito en la public-subnet-1 como indicamos, por lo cual podemos acceder sin problema
    <p align="center">
        <img src="https://user-images.githubusercontent.com/30850990/159194449-ac011370-7834-4b78-902a-739119ce59cd.png"/>
    </p>
    <p align="center">
        <img src="https://user-images.githubusercontent.com/30850990/159194542-8fe8d825-d887-42a4-a1c0-0fe142a89687.png"/>
    </p>
<br/>

## Referencias
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
- https://www.terraform.io/
    - https://www.terraform.io/language/settings/backends
    - https://www.terraform.io/cli/commands/init
    - https://www.terraform.io/language/modules/develop
    - https://www.terraform.io/language/functions/cidrsubnet
- https://www.terraform-best-practices.com/code-structure