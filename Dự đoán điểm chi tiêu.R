install.packages("tidyverse")
install.packages("ggplot2")
install.packages("caret")
install.packages("Metrics")
install.packages("reshape2")
install.packages("dplyr")
# Load thư viện cần thiết
library(tidyverse)
library(ggplot2)
library(caret)
library(Metrics)
library(reshape2)

# Đọc dữ liệu RFM từ file
file_path <- "D:/Tập dữ liệu BigDaTa/RFM_Segmentation.csv"
rfm_df <- read.csv(file_path)

# Chuyển đổi kiểu dữ liệu nếu cần
rfm_df$CustomerID <- as.character(rfm_df$CustomerID)

# Chia dữ liệu thành tập train và test
set.seed(123)  
sample_index <- sample(1:nrow(rfm_df), 0.8 * nrow(rfm_df))
train_data <- rfm_df[sample_index, ]
test_data <- rfm_df[-sample_index, ]

# Xây dựng mô hình hồi quy tuyến tính dự đoán Monetary Score
tlm_model <- lm(M_Score ~ Recency + Frequency + Monetary, data = train_data)

# Dự đoán trên tập kiểm tra
test_data$Predicted_M_Score <- predict(tlm_model, test_data)

# Biểu đồ phân phối điểm chi tiêu dự đoán
ggplot(test_data, aes(x = round(Predicted_M_Score))) +
  geom_bar(fill = "steelblue", color = "black", alpha = 0.7) +
  geom_text(stat = "count", aes(label = ..count..), vjust = -0.5, size = 5) +
  theme_bw() +
  labs(title = "Phân phối Điểm Chi Tiêu Dự Đoán", 
       x = "Điểm Chi Tiêu Dự Đoán (Làm tròn)", 
       y = "Số lượng khách hàng") +
  theme(plot.title = element_text(hjust = 0.5))

# Tính toán các chỉ số đánh giá mô hình
actual <- test_data$M_Score
predicted <- test_data$Predicted_M_Score

rmse_value <- rmse(actual, predicted)
mae_value <- mae(actual, predicted)
r2_value <- cor(actual, predicted)^2

# Hiển thị kết quả
cat("RMSE:", rmse_value, "\n")
cat("MAE:", mae_value, "\n")
cat("R²:", r2_value, "\n")

# Chọn ngẫu nhiên 20 khách hàng để so sánh dự đoán và thực tế
set.seed(123)  
sample_test <- test_data[sample(nrow(test_data), 20), ]

# Chuyển đổi dữ liệu thành dạng phù hợp để vẽ
sample_test_melt <- melt(sample_test, id.vars = "CustomerID", 
                         measure.vars = c("M_Score", "Predicted_M_Score"),
                         variable.name = "Chú_thích", value.name = "Diem_Chi_Tieu")

# Đổi tên nhãn cột
sample_test_melt$Chú_thích <- dplyr::recode(sample_test_melt$Chú_thích, 
                                            "M_Score" = "Điểm Chi Tiêu Thực Tế", 
                                            "Predicted_M_Score" = "Điểm Chi Tiêu Dự Đoán")

# Biểu đồ so sánh thực tế vs dự đoán
ggplot(sample_test_melt, aes(x = CustomerID, y = Diem_Chi_Tieu, fill = Chú_thích)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Điểm Chi Tiêu Thực Tế" = "blue", "Điểm Chi Tiêu Dự Đoán" = "red")) +
  theme_bw() +
  labs(title = "Đánh giá mô hình: So sánh Điểm Chi Tiêu", 
       x = "Khách hàng", y = "Điểm Chi Tiêu", fill = "Chú thích") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5))

