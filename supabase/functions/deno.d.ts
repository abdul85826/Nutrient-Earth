// ==============================================================================
// Nutrient Earth — Ambient Deno Definitions for Supabase Edge Functions
// Provides Deno namespace and global runtime symbols for TypeScript language server
// ==============================================================================

declare namespace Deno {
  export interface Env {
    get(key: string): string | undefined;
    set(key: string, value: string): void;
    delete(key: string): void;
    toObject(): Record<string, string>;
  }

  export const env: Env;
}

declare module 'https://*' {
  const content: any;
  export default content;
  export const serve: any;
  export const createClient: any;
}
