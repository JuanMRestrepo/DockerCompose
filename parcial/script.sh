#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# URL base de la API
BASE_URL="http://localhost:8081/api/products"

# Variables para almacenar IDs
PRODUCT_ID=""

echo -e "${BLUE}===== SCRIPT DE PRUEBA DE ENDPOINTS DE MICROSERVICIO DE PRODUCTOS CON DOCKER COMPOSE =====${NC}"
echo -e "${BLUE}Este script ejecutará docker-compose y probará todos los endpoints CRUD de la API de productos.${NC}"
echo ""

# Función para iniciar los contenedores con Docker Compose
start_containers() {
  echo -e "${YELLOW}Iniciando los contenedores con Docker Compose...${NC}"
  
  # Detener cualquier contenedor anterior si existe (no falla si no existen)
  docker-compose down --remove-orphans > /dev/null 2>&1
  
  # Iniciar los contenedores en modo detached
  if docker-compose up --build -d; then
    echo -e "${GREEN}✓ Contenedores iniciados exitosamente${NC}"
  else
    echo -e "${RED}✗ Error al iniciar los contenedores${NC}"
    exit 1
  fi
}

# Función para esperar a que la API esté disponible
wait_for_api() {
  echo -e "${YELLOW}Esperando a que la API esté disponible...${NC}"
  
  # Contador para limitar el tiempo de espera
  counter=0
  max_tries=10
  
  while [ $counter -lt $max_tries ]; do
    response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL)
    
    if [ $response -eq 200 ]; then
      echo -e "${GREEN}✓ La API está disponible (HTTP $response)${NC}"
      return 0
    else
      echo -e "${YELLOW}Esperando a que la API esté lista... intento $((counter+1))/$max_tries${NC}"
      counter=$((counter+1))
      sleep 3
    fi
  done
  
  echo -e "${RED}✗ La API no se ha iniciado después de múltiples intentos${NC}"
  echo -e "${YELLOW}Verificando logs de los contenedores...${NC}"
  docker-compose logs --tail=50 app
  exit 1
}

# Función para verificar si la API está disponible
check_api() {
  echo -e "${YELLOW}Verificando si la API está disponible...${NC}"
  
  response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL)
  
  if [ $response -eq 200 ]; then
    echo -e "${GREEN}✓ La API está disponible (HTTP $response)${NC}"
    return 0
  else
    echo -e "${RED}✗ La API no está disponible (HTTP $response)${NC}"
    echo -e "${YELLOW}Asegúrate de que los contenedores estén ejecutándose correctamente${NC}"
    exit 1
  fi
}

# Función para crear un producto
create_product() {
  echo -e "\n${YELLOW}1. Creando un nuevo producto...${NC}"
  
  response=$(curl -s -X POST $BASE_URL \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Producto de Prueba",
        "description": "Este es un producto creado por el script de prueba",
        "price": 99.99,
        "stock": 50
    }')
  
  if [ $? -eq 0 ] && [[ $response == *"id"* ]]; then
    echo -e "${GREEN}✓ Producto creado exitosamente${NC}"
    echo -e "${BLUE}Respuesta: $response${NC}"
    
    # Extraer el ID del producto creado
    PRODUCT_ID=$(echo $response | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
    echo -e "${YELLOW}ID del producto creado: $PRODUCT_ID${NC}"
    return 0
  else
    echo -e "${RED}✗ Error al crear el producto${NC}"
    echo -e "${RED}Respuesta: $response${NC}"
    return 1
  fi
}

# Función para obtener todos los productos
get_all_products() {
  echo -e "\n${YELLOW}2. Obteniendo todos los productos...${NC}"
  
  response=$(curl -s $BASE_URL)
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Productos obtenidos exitosamente${NC}"
    echo -e "${BLUE}Respuesta: $response${NC}"
    return 0
  else
    echo -e "${RED}✗ Error al obtener los productos${NC}"
    return 1
  fi
}

# Función para obtener un producto por ID
get_product_by_id() {
  echo -e "\n${YELLOW}3. Obteniendo el producto con ID $PRODUCT_ID...${NC}"
  
  response=$(curl -s $BASE_URL/$PRODUCT_ID)
  
  if [ $? -eq 0 ] && [[ $response == *"id"* ]]; then
    echo -e "${GREEN}✓ Producto obtenido exitosamente${NC}"
    echo -e "${BLUE}Respuesta: $response${NC}"
    return 0
  else
    echo -e "${RED}✗ Error al obtener el producto${NC}"
    echo -e "${RED}Respuesta: $response${NC}"
    return 1
  fi
}

# Función para buscar productos por nombre
search_products() {
  echo -e "\n${YELLOW}4. Buscando productos por nombre 'Prueba'...${NC}"
  
  response=$(curl -s "$BASE_URL/search?name=Prueba")
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Búsqueda realizada exitosamente${NC}"
    echo -e "${BLUE}Respuesta: $response${NC}"
    return 0
  else
    echo -e "${RED}✗ Error en la búsqueda${NC}"
    return 1
  fi
}

# Función para obtener productos por precio máximo
get_products_by_price() {
  echo -e "\n${YELLOW}5. Obteniendo productos con precio máximo de 100.00...${NC}"
  
  response=$(curl -s "$BASE_URL/price?maxPrice=100.00")
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Productos filtrados por precio exitosamente${NC}"
    echo -e "${BLUE}Respuesta: $response${NC}"
    return 0
  else
    echo -e "${RED}✗ Error al filtrar por precio${NC}"
    return 1
  fi
}

# Función para obtener productos en stock
get_products_in_stock() {
  echo -e "\n${YELLOW}6. Obteniendo productos con stock mayor a 10...${NC}"
  
  response=$(curl -s "$BASE_URL/instock?minStock=10")
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Productos filtrados por stock exitosamente${NC}"
    echo -e "${BLUE}Respuesta: $response${NC}"
    return 0
  else
    echo -e "${RED}✗ Error al filtrar por stock${NC}"
    return 1
  fi
}

# Función para actualizar un producto
update_product() {
  echo -e "\n${YELLOW}7. Actualizando el producto con ID $PRODUCT_ID...${NC}"
  
  response=$(curl -s -X PUT $BASE_URL/$PRODUCT_ID \
    -H "Content-Type: application/json" \
    -d '{
        "name": "Producto Actualizado",
        "description": "Esta descripción ha sido actualizada por el script de prueba",
        "price": 149.99,
        "stock": 75
    }')
  
  if [ $? -eq 0 ] && [[ $response == *"id"* ]]; then
    echo -e "${GREEN}✓ Producto actualizado exitosamente${NC}"
    echo -e "${BLUE}Respuesta: $response${NC}"
    return 0
  else
    echo -e "${RED}✗ Error al actualizar el producto${NC}"
    echo -e "${RED}Respuesta: $response${NC}"
    return 1
  fi
}

# Función para eliminar un producto
delete_product() {
  echo -e "\n${YELLOW}8. Eliminando el producto con ID $PRODUCT_ID...${NC}"
  
  response=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE $BASE_URL/$PRODUCT_ID)
  
  if [ $? -eq 0 ] && [ $response -eq 204 ]; then
    echo -e "${GREEN}✓ Producto eliminado exitosamente (HTTP $response)${NC}"
    
    # Verificar que el producto ya no existe
    echo -e "${YELLOW}Verificando que el producto ya no existe...${NC}"
    verify_response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/$PRODUCT_ID)
    
    if [ $verify_response -eq 404 ]; then
      echo -e "${GREEN}✓ Verificación exitosa: el producto ya no existe (HTTP $verify_response)${NC}"
    else
      echo -e "${RED}✗ Verificación fallida: el producto todavía existe (HTTP $verify_response)${NC}"
    fi
    
    return 0
  else
    echo -e "${RED}✗ Error al eliminar el producto (HTTP $response)${NC}"
    return 1
  fi
}

# Función para mostrar los logs de los contenedores
show_logs() {
  echo -e "\n${YELLOW}Mostrando los últimos logs de los contenedores...${NC}"
  docker-compose logs --tail=30
}

# Función para detener los contenedores (opcional)
stop_containers() {
  echo -e "\n${YELLOW}¿Deseas detener los contenedores? (s/n)${NC}"
  read -r answer
  
  if [[ "$answer" == "s" || "$answer" == "S" ]]; then
    echo -e "${YELLOW}Deteniendo los contenedores...${NC}"
    docker-compose down
    echo -e "${GREEN}✓ Contenedores detenidos${NC}"
  else
    echo -e "${GREEN}Los contenedores seguirán ejecutándose${NC}"
  fi
}

# Ejecutar todas las pruebas
run_all_tests() {
  check_api
  create_product
  get_all_products
  get_product_by_id
  search_products
  get_products_by_price
  get_products_in_stock
  update_product
  delete_product
  
  echo -e "\n${GREEN}===== PRUEBAS COMPLETADAS =====${NC}"
}

# Función de limpieza en caso de interrupción
cleanup() {
  echo -e "\n${YELLOW}Limpiando y saliendo...${NC}"
  exit 1
}

# Registrar la función de limpieza para señales de interrupción
trap cleanup SIGINT

# Función principal
main() {
  start_containers
  wait_for_api
  run_all_tests
  show_logs
  stop_containers
}

# Ejecutar la función principal
main