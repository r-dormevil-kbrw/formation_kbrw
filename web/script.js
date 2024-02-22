import { createRoot } from 'react-dom/client';
import React from 'react';

const App = () => {
	return (<JSXZ in="template" sel=".container">
         		<Z sel=".item">Burgers</Z>,
        		<Z sel=".price">50</Z>
		</JSXZ>);
}
const root = createRoot(document.getElementById('root'));
root.render(<App />);
