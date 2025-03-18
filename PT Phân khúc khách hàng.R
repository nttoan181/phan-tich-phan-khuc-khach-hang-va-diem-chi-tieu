# Cài đặt các gói cần thiết
install.packages("tidyverse")  # Bao gồm dplyr, ggplot2, v.v.
install.packages("lubridate")  # Hỗ trợ xử lý ngày tháng
install.packages("ggplot2")  # Vẽ biểu đồ
install.packages("dplyr")  # Xử lý dữ liệu
install.packages("scales")  # Định dạng tỷ lệ
install.packages("sparklyr")  # Làm việc với Spark
install.packages("dbplyr")  # Hỗ trợ truy vấn dữ liệu trên Spark
install.packages("maps")       # Dữ liệu bản đồ thế giới
install.packages("ggthemes")   # Chủ đề đẹp cho ggplot

# Nạp thư viện
library(tidyverse)
library(lubridate)
library(ggplot2)
library(dplyr)
library(scales)
library(sparklyr)
library(dbplyr)
library(maps)
library(ggthemes)

# Kết nối Spark (chạy local)
sc <- spark_connect(master = "local")

# Định nghĩa đường dẫn file dữ liệu
file_path <- "D:/BTLBigDaTa/Online Retail.csv"

# Đọc dữ liệu vào Spark DataFrame
df_spark <- spark_read_csv(sc, name = "retail_data", path = file_path, 
                           infer_schema = TRUE, delimiter = ",", header = TRUE)

# Kiểm tra tổng quan dữ liệu
df_spark %>% glimpse()

# Lọc bỏ các giá trị NA trong CustomerID và Description
df_spark <- df_spark %>%
  filter(!is.na(CustomerID) & !is.na(Description))

# Lọc bỏ các giao dịch có Quantity hoặc UnitPrice không hợp lệ
df_spark <- df_spark %>%
  filter(Quantity > 0, UnitPrice > 0)

# Chuyển đổi dữ liệu và tính toán giá trị mới
df_spark <- df_spark %>%
  mutate(
    InvoiceDate = to_date(InvoiceDate),  # Chuyển đổi ngày tháng
    CustomerID = as.character(CustomerID),  # Chuyển CustomerID thành kiểu ký tự
    TotalPrice = Quantity * UnitPrice,  # Tính tổng tiền từng giao dịch
    Year = year(InvoiceDate)  # Lấy năm từ ngày giao dịch
  )

# Tính tổng doanh thu theo quốc gia
revenue_by_country <- df_spark %>%
  group_by(Country) %>%
  summarise(TotalRevenue = sum(TotalPrice, na.rm = TRUE)) %>%
  arrange(desc(TotalRevenue)) %>%
  collect()

# Hiển thị top 10 quốc gia có doanh thu cao nhất
head(revenue_by_country, 10)

# Vẽ biểu đồ cột doanh thu theo quốc gia (Top 10)
ggplot(head(revenue_by_country, 10), aes(x = reorder(Country, TotalRevenue), y = TotalRevenue)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_text(aes(label = scales::comma(TotalRevenue)), hjust = -0.2, size = 5) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 10 quốc gia có doanh thu cao nhất", x = "Quốc gia", y = "Doanh thu")

# Thêm tọa độ (kinh độ, vĩ độ) cho một số quốc gia phổ biến trong dataset
country_coords <- data.frame(
  Country = c("United Kingdom", "France", "Germany", "EIRE", "Spain", "Netherlands"),
  long = c(-0.1276, 2.3522, 10.4515, -7.6921, -3.7038, 5.2913),
  lat = c(51.5074, 48.8566, 51.1657, 53.4129, 40.4168, 52.1326)
)

# Gộp vào dữ liệu doanh thu theo quốc gia
revenue_by_country <- revenue_by_country %>%
  inner_join(country_coords, by = "Country")

# Vẽ bản đồ với các điểm thể hiện doanh thu
ggplot() +
  geom_map(data = world_map, map = world_map,
           aes(map_id = region), fill = "gray90", color = "white") +
  geom_point(data = revenue_by_country, 
             aes(x = long, y = lat, size = TotalRevenue, color = TotalRevenue),
             alpha = 0.7) +
  scale_size_continuous(range = c(2, 10)) +
  scale_color_gradient(low = "blue", high = "red") +
  theme_minimal() +
  labs(title = "Doanh thu theo quốc gia", x = "Kinh độ", y = "Vĩ độ")

# Xác định 10 sản phẩm bán chạy nhất
top_products <- df_spark %>%
  group_by(Description) %>%
  summarise(TotalQuantity = sum(Quantity)) %>%
  arrange(desc(TotalQuantity)) %>%
  head(10) %>%
  collect()

# Vẽ biểu đồ top 10 sản phẩm bán chạy
ggplot(top_products, aes(x = reorder(Description, TotalQuantity), y = TotalQuantity)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_text(aes(label = TotalQuantity), hjust = -0.2, size = 5) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 10 sản phẩm bán chạy", x = "Sản phẩm", y = "Số lượng bán")

# Xác định ngày giao dịch mới nhất
latest_date <- df_spark %>%
  summarise(MaxDate = max(InvoiceDate)) %>%
  collect() %>%
  pull(MaxDate)

# Đảm bảo InvoiceDate có kiểu ngày hợp lệ
df_spark <- df_spark %>%
  mutate(InvoiceDate = to_date(InvoiceDate))

# Tính toán RFM (Recency, Frequency, Monetary)
rfm_df <- df_spark %>%
  group_by(CustomerID) %>%
  summarise(
    Recency = as.numeric(datediff(max(InvoiceDate), latest_date)),  # Khoảng thời gian từ giao dịch gần nhất
    Frequency = n_distinct(InvoiceNo),  # Số lần mua hàng
    Monetary = sum(TotalPrice, na.rm = TRUE)  # Tổng số tiền đã chi tiêu
  ) %>%
  mutate(
    R_Score = ntile(-Recency, 5),
    F_Score = ntile(Frequency, 5),
    M_Score = ntile(Monetary, 5),
    RFM_Score = R_Score * 100 + F_Score * 10 + M_Score
  ) %>%
  mutate(
    Segment = case_when(
      RFM_Score >= 555 ~ "VIP",
      RFM_Score >= 444 ~ "Trung thành",
      RFM_Score >= 333 ~ "Tiềm năng",
      RFM_Score >= 222 ~ "Khách không thường xuyên",
      TRUE ~ "Khách vãng lai"
    )
  ) %>%
  collect()

# Vẽ biểu đồ cột phân khúc khách hàng
ggplot(rfm_df, aes(x = Segment, fill = Segment)) +
  geom_bar() +
  labs(title = "Phân khúc khách hàng theo RFM", x = "Phân khúc", y = "Số lượng khách hàng") +
  theme_minimal() +
  theme(legend.position = "none")

# Vẽ biểu đồ tròn với nhãn % 
rfm_pie <- rfm_df %>%
  group_by(Segment) %>%
  summarise(Count = n()) %>%
  mutate(Percentage = Count / sum(Count) * 100)

ggplot(rfm_pie, aes(x = "", y = Percentage, fill = Segment)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  geom_text(aes(label = paste0(round(Percentage, 1), "%")), position = position_stack(vjust = 0.5)) +
  theme_void() +
  labs(title = "Tỷ lệ phân khúc khách hàng theo RFM")

# Xuất dữ liệu sạch và kết quả phân khúc ra file CSV
write.csv(rfm_df, "D:/BTLBigData/RFM_Segmentation.csv", row.names = FALSE)

# Ngắt kết nối Spark
spark_disconnect(sc)
