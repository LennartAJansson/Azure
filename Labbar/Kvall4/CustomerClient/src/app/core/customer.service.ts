import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { AppConfig } from './app-config';

/** Matchar CustomerDto i CustomersApi (Id är en Guid). */
export interface Customer {
  id: string;
  name: string;
  email?: string | null;
  phone?: string | null;
  city?: string | null;
  createdAt?: string;
  updatedAt?: string | null;
}

/** Matchar CustomerRequest. */
export interface NewCustomer {
  name: string;
  email?: string;
  phone?: string;
  city?: string;
}

/** Anpassa sökvägarna här om CustomersApi har andra routes. */
@Injectable({ providedIn: 'root' })
export class CustomerService {
  private readonly http = inject(HttpClient);
  private readonly config = inject(AppConfig);

  private url(path: string): string {
    return `${this.config.apiBaseUrl()}${path}`;
  }

  list(): Observable<Customer[]> {
    return this.http.get<Customer[]>(this.url('/customers'));
  }

  create(customer: NewCustomer): Observable<Customer> {
    return this.http.post<Customer>(this.url('/customers'), customer);
  }

  remove(id: string): Observable<void> {
    return this.http.delete<void>(this.url(`/customers/${id}`));
  }

  health(): Observable<unknown> {
    return this.http.get(this.url('/healthz'), { responseType: 'text' });
  }

  whoami(): Observable<unknown> {
    return this.http.get(this.url('/db/whoami'));
  }
}
