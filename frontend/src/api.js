import axios from "axios";

const apiEndpoint = process.env.REACT_APP_BASE_ENDPOINT;

const api = axios.create({
  baseURL: apiEndpoint,
});

api.interceptors.request.use(
  function (config) {
    const token = localStorage.getItem("access-token");

    if (token) {
      config.headers = config.headers || {};
      config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
  },
  function (error) {
    return Promise.reject(error);
  }
);

export const fetchProductList = async ({ pageParam = 1 }) => {
  const { data } = await api.get(`/product?page=${pageParam}`);

  return data;
};

export const fetchProduct = async (id) => {
  const { data } = await api.get(`/product/${id}`);

  return data;
};

export const postProduct = async (input) => {
  const { data } = await api.post("/product", input);

  return data;
};

export const fetcRegister = async (input) => {
  const { data } = await api.post("/auth/register", input);

  return data;
};

export const fetchLogin = async (input) => {
  const { data } = await api.post("/auth/login", input);

  return data;
};

export const fetchMe = async () => {
  const { data } = await api.get("/auth/me");
  return data;
};

export const fetchLogout = async () => {
  const { data } = await api.post("/auth/logout", {
    refresh_token: localStorage.getItem("refresh-token"),
  });
  return data;
};

export const postOrder = async (input) => {
  const { data } = await api.post("/order", input);
  return data;
};

export const fetchOrders = async () => {
  const { data } = await api.get("/order");
  return data;
};

export const deleteProduct = async (product_id) => {
  const { data } = await api.delete(`/product/${product_id}`);

  return data;
};

export const updateProduct = async (input, product_id) => {
  const { data } = await api.put(`/product/${product_id}`, input);

  return data;
};
