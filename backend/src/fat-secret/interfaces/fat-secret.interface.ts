export interface FsTokenResponse {
  access_token: string;
  token_type: string;
  expires_in: number;
}

export interface FsSearchFood {
  food_id: string;
  food_name: string;
  food_description: string;
  brand_name?: string;
  food_type: string;
  food_url: string;
}

export interface FsSearchResponse {
  foods?: {
    food?: FsSearchFood | FsSearchFood[];
    max_results: string;
    page_number: string;
    total_results: string;
  };
}

export interface FsServing {
  serving_id: string;
  serving_description: string;
  metric_serving_amount?: string;
  metric_serving_unit?: string;
  calories?: string;
  protein?: string;
  fat?: string;
  carbohydrate?: string;
  fiber?: string;
  sugar?: string;
  sodium?: string;
}

export interface FsGetFoodResponse {
  food?: {
    food_id: string;
    food_name: string;
    brand_name?: string;
    servings?: {
      serving?: FsServing | FsServing[];
    };
  };
}

export interface FsBarcodeResponse {
  food_id?: {
    value: string;
  };
}
