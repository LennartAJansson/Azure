import { Routes } from '@angular/router';
import { Customers } from './customers/customers';
import { Status } from './status/status';

export const routes: Routes = [
  { path: '', component: Customers },
  { path: 'status', component: Status },
  { path: '**', redirectTo: '' },
];
