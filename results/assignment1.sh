# #!/bin/bash
echo "=== Assignment 1: k-NN Consistency Check ===" > results/assignment-1-endpoints.txt
echo "Timestamp: $(date)" >> results/assignment-1-endpoints.txt
echo "----------------------------------------" >> results/assignment-1-endpoints.txt

PAYLOAD='{"body": "{\"query\": [0.4967, -0.1382, 0.6476, 1.5230, -0.2341, -0.2341, 1.5792, 0.7674, -0.4694, 0.5425, -0.4634, -0.4657, 0.2419, -1.9132, -1.7249, -0.5622, -1.0128, 0.3142, -0.9080, -1.4123, 1.4656, -0.2257, 0.0675, -1.4247, -0.5443, 0.1109, -1.1509, 0.3756, -0.6006, -0.2916, -0.6017, 1.8522, -0.0134, -1.0577, 0.8225, -1.2208, 0.2088, -1.9596, -1.3281, 0.1968, 0.7384, 0.1713, -0.1156, -0.3011, -1.4785, -0.7198, -0.4606, 1.0571, 0.3436, -1.7630, 0.3240, -0.3850, -0.6769, 0.6116, 1.0309, 0.9312, -0.8392, -0.3092, 0.3312, 0.9755, -0.4791, -0.1856, -1.1063, -1.1962, 0.8125, 1.3562, -0.0720, 1.0035, 0.3616, -0.6451, 0.3613, 1.5380, -0.0358, 1.5646, -2.6197, 0.8219, 0.0870, -0.2990, 0.0917, -1.9875, -0.2196, 0.3571, 1.4778, -0.5182, -0.8084, -0.5017, 0.9154, 0.3287, -0.5297, 0.5132, 0.0970, 0.9686, -0.7020, -0.3276, -0.3921, -1.4635, 0.2961, 0.2610, 0.0051, -0.2345, -1.4153, -0.4206, -0.3427, -0.8022, -0.1612, 0.4040, 1.8861, 0.1745, 0.2575, -0.0744, -1.9187, -0.0265, 0.0602, 2.4632, -0.1923, 0.3015, -0.0347, -1.1686, 1.1428, 0.7519, 0.7910, -0.9093, 1.4027, -1.4018, 0.5868, 2.1904, -0.9905, -0.5662]}"}'

source "loadtest/endpoints.sh"

endpoints=(
  "LAMBDA_ZIP|lsc-knn-zip"
  "LAMBDA_CONTAINER|lsc-knn-container"
  "FARGATE|$FARGATE_URL"
  "EC2|$EC2_URL"
)

for row in "${endpoints[@]}"; do
  IFS="|" read -r name target <<< "$row"
  echo "Testing $name..."
  echo -e "\nTARGET: $name" >> results/assignment-1-endpoints.txt
  
  if [[ "$name" == "LAMBDA"* ]]; then
      aws lambda invoke \
          --function-name "$target" \
          --payload "$PAYLOAD" \
          --cli-binary-format raw-in-base64-out \
          --region us-east-1 \
          temp_res.json > /dev/null
      
      cat temp_res.json >> results/assignment-1-endpoints.txt
      rm temp_res.json
  else
      curl -s -X POST -H "Content-Type: application/json" -d @loadtest/query.json "$target/search" >> results/assignment-1-endpoints.txt
  fi
  
  echo -e "\n----------------------------------------" >> results/assignment-1-endpoints.txt
done