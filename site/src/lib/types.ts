export interface Product {
  id: string;
  label: string;
  image: string;
  monogram: string;
  featured: boolean;
  count: number;
}

export interface Author {
  handle: string;
  name: string;
  pictureUrl: string;
}

export interface Contributor extends Author {
  count: number;
}

export interface Tool {
  id: string;
  label: string;
  version: string;
}

export interface Sample {
  slug: string;
  title: string;
  description: string;
  products: string[];
  categories: string[];
  tags: string[];
  tools: Tool[];
  created: string;
  updated: string;
  authors: Author[];
  references: { name: string; description: string; url: string }[];
  sourceUrl: string;
  url: string;
  legacyUrl: string;
  previews: { src: string; alt: string }[];
  commandReferences: { name: string; url: string }[];
  search: string;
  readmeHtml: string;
  scriptTabCount: number;
  codeBlockCount: number;
}

export interface Guide {
  source: string;
  route: string;
  title: string;
  html: string;
}

export interface Catalog {
  version: number;
  samples: Sample[];
  products: Product[];
  tools: { id: string; label: string; count: number }[];
  categories: string[];
  contributors: Contributor[];
  guides: Guide[];
  redirects: Record<string, string>;
}
