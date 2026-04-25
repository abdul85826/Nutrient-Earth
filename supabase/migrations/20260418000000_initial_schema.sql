create table users (
  id uuid primary key default auth.uid(),
  name text,
  age int,
  city text,
  main_problem text,
  language text default 'en',
  created_at timestamp default now()
);

create table health_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  sugar int,
  bp int,
  weight int,
  energy_level int,
  stress_level int,
  created_at timestamp default now()
);

create table daily_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  steps jsonb,
  completed boolean default false,
  created_at timestamp default now()
);

create table organ_states (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  pancreas int default 30,
  heart int default 40,
  lungs int default 50,
  updated_at timestamp default now()
);

create table points (
  user_id uuid primary key references users(id),
  total int default 0
);

create table streaks (
  user_id uuid primary key references users(id),
  current_streak int default 0,
  last_active_date date
);

create table products (
  id uuid primary key default gen_random_uuid(),
  name text,
  price int,
  category text,
  benefits text,
  stock int,
  location text,
  created_at timestamp default now()
);

create table orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id),
  product_id uuid references products(id),
  amount int,
  status text,
  created_at timestamp default now()
);

create table success_stories (
  id uuid primary key default gen_random_uuid(),
  name text,
  before_value int,
  after_value int,
  days int,
  problem_type text,
  story text
);

create table flow_content (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  type text,
  topic text,
  content_url text,
  caption text,
  likes int default 0,
  created_at timestamp default now()
);
